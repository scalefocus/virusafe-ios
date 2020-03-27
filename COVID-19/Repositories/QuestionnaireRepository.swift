//
//  QuestionnaireRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 24.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

typealias RequestQuestionCompletion = ((ApiResult<HealthStatus>) -> Void)
typealias SendAnswersCompletion = ((ApiResult<Void>) -> Void)

protocol QuestionnaireRepositoryProtocol {
    func requestQuestions(with completion: @escaping RequestQuestionCompletion)
    func sendAnswers(_ answers: [HealthStatusQuestion],
                     for phoneNumber: String,
                     at latitude: Double,
                     longitude: Double,
                     with completion: @escaping SendAnswersCompletion)
}

class QuestionnaireRepository: QuestionnaireRepositoryProtocol {
    // There are 2 ways to access the data with the apiManager ->
    // 1) executeParsed() which required a concrete (normally codable) type to parse the data
    // and the data will be parsed internally in the api manager
    // 2) execute() which doesn't parse and just returns data
    // P.S -> In many cases you should use the extension executeParsedWithHandling() and executeWithHandling()
    // which adds error handling/showing alerts/etc
    func requestQuestions(with completion: @escaping RequestQuestionCompletion) {
        QuestionsApiRequest().executeParsed(of: [Question].self) { (questions, response, error) in
            guard let statusCode = response?.statusCode, error == nil else {
                completion(.failure(.general))
                return
            }

            let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

            switch statusCodeResult {
                case .succes:
                    let healthStatus = HealthStatus(questions:
                        questions?.map { HealthStatusQuestion(questionId: $0.identifier, questionTitle: $0.title, isActive: nil) }
                    )
                    completion(.success(healthStatus))
                case .failure:
                    // No special handling
                    completion(.failure(.server))
            }
        }
    }

    func sendAnswers(_ answers: [HealthStatusQuestion],
                     for phoneNumber: String,
                     at latitude: Double,
                     longitude: Double,
                     with completion: @escaping SendAnswersCompletion) {
        let results: [Answer] = answers.map {
            Answer(answer: "\($0.isActive ?? false)", questionId: $0.questionId)
        }

        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let questionnaire = Questionnaire(answers: results, location: location, timestamp: timestamp)

        AnswersApiRequest(with: questionnaire, phoneNumber: phoneNumber).execute { (data, response, error) in
            guard let statusCode = response?.statusCode, error == nil else {
                completion(.failure(.general))
                return
            }

            let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

            switch statusCodeResult {
                case .succes:
                    completion(.success(Void()))
                case .failure(let reason):
                    switch reason {
                        case .tooManyRequests:
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let response = try? decoder.decode(TooManyRequestsResponse.self, from: data ?? Data())
                            let seconds = Int(response?.message ?? "3600") ?? 3600 // if not set return 1 hour by default
                            completion(.failure(.tooManyRequests(reapeatAfter: seconds)))
                        default:
                            // No special handling
                            completion(.failure(.server))
                    }
            }
        }
    }
}

