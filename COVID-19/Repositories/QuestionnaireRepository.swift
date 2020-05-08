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
    func requestQuestions(with locale: String, and completion: @escaping RequestQuestionCompletion)
    func sendAnswers(_ answers: [HealthStatusQuestion],
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
    func requestQuestions(with locale: String, and completion: @escaping RequestQuestionCompletion) {
        QuestionsApiRequest(language: locale).executeParsedWithHandling(of: [Question].self) { (questions, response, error) in
            guard let statusCode = response?.statusCode, error == nil else {
                completion(.failure(.general))
                return
            }

            let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

            switch statusCodeResult {
            case .success:
                let healthStatus = HealthStatus(questions:
                    questions?.map { HealthStatusQuestion(questionId: $0.identifier, questionTitle: $0.title, isActive: nil) }
                )
                completion(.success(healthStatus))
            case .failure:
                completion(.failure(.server))
            }
        }
    }

    func sendAnswers(_ answers: [HealthStatusQuestion],
                     at latitude: Double,
                     longitude: Double,
                     with completion: @escaping SendAnswersCompletion) {
        let results: [Answer] = answers.map {
            Answer(answer: "\($0.isActive ?? false)", questionId: $0.questionId)
        }

        let timestamp = "\(Int64(Date().timeIntervalSince1970 * 1000))"
        let location = UserLocation(latitude: latitude, longitude: longitude)
        let questionnaire = Questionnaire(answers: results, location: location, timestamp: timestamp)

        AnswersApiRequest(with: questionnaire).executeWithHandling { (data, response, error) in
            guard let statusCode = response?.statusCode, error == nil else {
                completion(.failure(.general))
                return
            }

            let statusCodeResult = ApiStatusCodeHandler.handle(statusCode: statusCode)

            switch statusCodeResult {
            case .success:
                completion(.success(Void()))
            case .failure(let reason):
                switch reason {
                case .tooManyRequests:
                    let reapeatAfter = TooManyRequestestHandler().handle(data: data)
                    completion(.failure(.tooManyRequests(reapeatAfter: reapeatAfter)))
                default:
                    // No special handling
                    completion(.failure(.server))
                }
            }
        }
    }
}
