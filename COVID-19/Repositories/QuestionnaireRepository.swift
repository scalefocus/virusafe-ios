//
//  QuestionnaireRepository.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 24.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import NetworkKit

typealias GetQuestionCompletion = ((HealthStatus?, Error?) -> Void)
typealias PostAnswersCompletion = ((Error?) -> Void)

protocol QuestionnaireRepositoryProtocol {
    func requestQuestions(with completion: @escaping GetQuestionCompletion)
    func sendAnswers(_ answers: [HealthStatusQuestion], for phoneNumber: String, with completion: @escaping PostAnswersCompletion)
}

class QuestionnaireRepository: QuestionnaireRepositoryProtocol {
    // There are 2 ways to access the data with the apiManager ->
    // 1) executeParsed() which required a concrete (normally codable) type to parse the data
    // and the data will be parsed internally in the api manager
    // 2) execute() which doesn't parse and just returns data
    // P.S -> In many cases you should use the extension executeParsedWithHandling() and executeWithHandling()
    // which adds error handling/showing alerts/etc
    func requestQuestions(with completion: @escaping GetQuestionCompletion) {
        QuestionsApiRequest().executeParsed(of: [Question].self) { (questions, _, error) in
            let results: [HealthStatusQuestion]? = questions?.map {
                HealthStatusQuestion(questionId: $0.identifier,
                                     questionTitle: $0.title,
                                     isActive: nil)
            }

            completion(((results != nil) ? HealthStatus(questions: results) : nil), error)
        }
    }

    func sendAnswers(_ answers: [HealthStatusQuestion], for phoneNumber: String, with completion: @escaping PostAnswersCompletion) {
        let results: [Answer] = answers.map {
            Answer(answer: "\($0.isActive ?? false)", questionId: $0.questionId)
        }
        // TODO: Actual location
        let location = UserLocation(latitude: 0, longitude: 0)
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let questionnaire = Questionnaire(answers: results, location: location, timestamp: timestamp)
        AnswersApiRequest(with: questionnaire, phoneNumber: phoneNumber).execute { (data, _, error) in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
            }
            completion(error)
        }
    }
}

