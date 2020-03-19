//
//  Networker.swift
//  NetworkKit
//
//  Created by Plamen Penchev on 4.09.18.
//

import Foundation
import Alamofire

public class Networker: NetworkingInterface {
    
    let networkReachabilityManager = NetworkReachabilityManager()
    private var sessionManager: SessionManager?
    
    weak public var delegate: ReachabilityProtocol?
    
    public func send(request: APIRequest, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        if let sessionManager = sessionManager {
            sessionManager.request(request.asUrlRequest()).response { (response) in
                completion(response.data, response.response, response.error)
            }
        } else {
            Alamofire.request(request.asUrlRequest()).response { (response) in
                completion(response.data, response.response, response.error)
            }
        }
    }
    
    public func isConnectedToInternet() -> Bool {
        // swiftlint:disable:next force_unwrapping
        return (networkReachabilityManager?.isReachable)!
    }
    
    public func startNetworkReachabilityObserver() {
        networkReachabilityManager?.startListening()
        delegate?.didChangeReachabilityStatus(isReachable: isConnectedToInternet())
        networkReachabilityManager?.listener = { [weak self] status in
            guard let strongSelf = self else { return }
            switch status {
                
            case .notReachable:
                strongSelf.delegate?.didChangeReachabilityStatus(isReachable: false)
                
            case .unknown :
                strongSelf.delegate?.didChangeReachabilityStatus(isReachable: false)
                
            case .reachable(.ethernetOrWiFi):
                strongSelf.delegate?.didChangeReachabilityStatus(isReachable: true)
                
            case .reachable(.wwan):
                strongSelf.delegate?.didChangeReachabilityStatus(isReachable: true)
            }
        }
    }
    
    public func configureWith(serverTrustPolicies: APITrustPolicies) {
        guard !serverTrustPolicies.isEmpty else { return }
        
        var serverTrustPolicy: [String: ServerTrustPolicy] = [:]
        serverTrustPolicies.forEach { (domain, policy) in
            switch policy {
            case .none:
                serverTrustPolicy[domain] = .disableEvaluation
            case .pinPublicKeys:
                serverTrustPolicy[domain] = .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(),
                                                           validateCertificateChain: true,
                                                           validateHost: true)
            case .pinCertificates:
                serverTrustPolicy[domain] = .pinCertificates(certificates: ServerTrustPolicy.certificates(),
                                                             validateCertificateChain: true,
                                                             validateHost: true)
            }
        }
        
        sessionManager = SessionManager(configuration: URLSessionConfiguration.default,
                                        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicy))
    }
}

public protocol ReachabilityProtocol: class {
    func didChangeReachabilityStatus(isReachable: Bool)
}
