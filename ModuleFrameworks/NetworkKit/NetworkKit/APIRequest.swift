//
//  APIRequest.swift
//  NetworkKit
//
//  Created by Valentin Kalchev on 23.05.18.
//  Copyright © 2018 Valentin Kalchev. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
}

private let defaultTimeout: TimeInterval = 30

/**
 Authorization requirement for current request.
 */
public enum AuthorizationRequirement {

    /// Request does not need authorization
    case none
    /// Request can have authorization, and may receive additional fields in response
    case allowed
    /// Request requires authorization
    case required
}

public protocol APIRequest {
    var httpMethod: HTTPMethod {get}

    /// Base url(<host.com>). Must NOT end with "/"
    var baseUrl: BaseURL {get}

    /// Base path of the endpoint, without any possible parameters. Must begin with "/" and must NOT end with "/"
    var path: String {get}

    /// Parameters added to the path http://domain.com/path/{parameter1}/{parameter2}.
    /// Not to be confused with query parameters
    var pathParameters: [String]? {get set}

    /// Query parameters added to the pathParams http://domain.com/path/parameter{?queryItem=value&queryItem2=value}
    /// Pass key as queryItem and value for it's value
    var queryParameters: [String: String]? {get set}

    /// Added to the body as JSON Data.
    /// Must be of a valid JSON seriaizable type,
    /// such as Array [], Dictionary {}, String "Some string" OR already encoded JSON Data
    var bodyJSONObject: Any? {get set}

    /// Added to the body as form urlencoded.
    var bodyFormURLEncoded: [String: String]? {get set}

    var authorizationRequirement: AuthorizationRequirement {get}
    var headers: [String: String] {get}

    var shouldHandleCookies: Bool? {get}
    var shouldCache: Bool {get}
    var timeout: TimeInterval {get}
    var tokenRefreshCount: Int? {get set}

    var customCachingIdentifier: String? {get}
    var customCachingIdentifierParams: [String: String]? {get set}

    init(pathParameters: [String]?, queryParameters: [String: String]?,
         bodyJSONObject: Any?, bodyFormURLEncoded: [String: String]?,
         parser: ParserInterface?,
         tokenRefreshCount: Int?,
         customCachingIdentifierParams: [String: String]?)

    var parser: ParserInterface? {get set}

    var shouldWorkInBackground: Bool { get }
}

extension APIRequest {
    func asUrlRequest() -> URLRequest {

        // swiftlint:disable:next force_unwrapping
        var urlRequest = URLRequest(url: endpoint!)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = httpMethod.rawValue

        // Set the http body, if a bodyJsonObject has been provided.
        if let bodyJSONObject = bodyJSONObject {
            // In case already encoded Data has been provided
            if let jsonData = bodyJSONObject as? Data {
                urlRequest.httpBody = jsonData
            } else {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: bodyJSONObject)
                    urlRequest.httpBody = jsonData
                } catch {
                    print("ERROR serializing json body object for: \(path): \(error.localizedDescription)")
                }
            }
        }

        /// Set the http body, if bodyFormURLEncoded has been provided.
        if let bodyFormURLEncoded = bodyFormURLEncoded {
            urlRequest.encodeParameters(parameters: bodyFormURLEncoded)
        }

        if let shouldHandleCookies = shouldHandleCookies {
            urlRequest.httpShouldHandleCookies = shouldHandleCookies
        }
        urlRequest.timeoutInterval = timeout ?? defaultTimeout

        return urlRequest
    }

    public func execute(completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        APIManager.shared.sendRequest(request: self, completion: completion)
    }

    /// Executes the request and returns the actual parsed model in the callback.
    ///
    /// - Parameters:
    ///   - type: The model type to be parsed to.
    ///   - completion: callback (ParsedModel?, HTTPURLResponse?, Error?)
    public func executeParsed<T: Codable>(of type: T.Type, completion: @escaping (T?, HTTPURLResponse?, Error?) -> Void) {
        execute { (data, urlResponse, error) in
            var parsedData: T?
            guard let data = data else {
                completion(parsedData, urlResponse, error)
                return
            }
            if let parser = self.parser {
                parsedData = parser.parse(data: data, ofType: type)
            } else {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                parsedData = try? decoder.decode(type, from: data)
            }
            completion(parsedData, urlResponse, error)
        }
    }

    public var endpoint: URL? {
        guard var url = URL(string: baseUrl) else {
            // Bad base url
            return nil
        }

        // Add endpoint path
        // NOTE: This way we don't care if path starts with / or not
        url.appendPathComponent(path)

        // Safe append other path components
        if let pathParameters = pathParameters {
            url.appendPathComponents(pathParameters)
        }

        // Insert query items
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        return urlComponents?.url
    }
}

// Support for parsing dict as form urlencoded content type
extension URLRequest {

    private func percentEscapeString(_ string: String) -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")

        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)?
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }

    mutating func encodeParameters(parameters: [String: String]) {
        let parameterArray = parameters.compactMap { (arg) -> String in
            let (key, value) = arg
            guard let escpaedValue = percentEscapeString(value) else { return "\(key)=" }
            return "\(key)=\(escpaedValue)"
        }

        httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
