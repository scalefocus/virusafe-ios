//
//  HealthStatusViewModel.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage

class HealthStatusViewModel {
    
    typealias NoSymptomsCellConfigurator = BaseViewConfigurator<NoSymptomsTableViewCell>
    typealias QuestionCellConfigurator = BaseViewConfigurator<QuestionTableViewCell>

    // state
    
    private var configurators: [ViewConfigurator] = []
    private var healthStatusData: HealthStatus?

    // Observables

    let shouldReloadData = Observable<Bool>()
    let isLeavingScreenAvailable = Observable<Bool>()
    let reloadCellIndexPath = Observable<IndexPath>()
    let shouldShowLoadingIndicator = Observable<Bool>()
    let isRequestQuestionsSuccessful = Observable<Bool>()
    let isSendAnswersSuccessful = Observable<Bool>()

    // Helpers
    
    private var hasEmptyFields: Bool {
        guard let questions = healthStatusData?.questions else { return true }
        var hasEmpty = false
        for question in questions where question.isActive == nil {
            hasEmpty = true
            break
        }
        return hasEmpty
    }
    
    private var areAllFieldsNegative: Bool {
        guard let questions = healthStatusData?.questions else { return false }
        var areAllNegative = true
        for question in questions where question.isActive == true || question.isActive == nil {
            areAllNegative = false
            break
        }
        return areAllNegative
    }
    
    var numberOfCells: Int {
        return configurators.count
    }
    
    func viewConfigurator(at index: Int, in section: Int) -> ViewConfigurator? {
        return configurators[safeAt: index] ?? nil
    }
    
    private func didTapNoSymptomsButton(isActive: Bool) {
        (configurators[safeAt: 0] as? NoSymptomsCellConfigurator)?.data.hasSymptoms = isActive
        configurators.forEach { (configurator) in
            if let conf = configurator as? QuestionCellConfigurator {
                conf.data.isSymptomActive = isActive ? false : nil
                healthStatusData?.questions?[conf.data.index].isActive = isActive ? false : nil
            }
        }

        shouldReloadData.value = true
    }
    
    func didTapSubmitButton() {
        isLeavingScreenAvailable.value = !hasEmptyFields
    }
    
    private func updateSymptoms(for index: Int, hasSymptoms: Bool) {
        healthStatusData?.questions?[index].isActive = hasSymptoms
        
        (configurators[safeAt: 0] as? NoSymptomsCellConfigurator)?.data.hasSymptoms = areAllFieldsNegative
        reloadCellIndexPath.value = IndexPath(item: 0, section: 0)
    }

    // TODO: Refactor - split this function it is too long
    func getHealthStatusData() {
        // show activity indicator
        shouldShowLoadingIndicator.value = true
        QuestionnaireRepository().requestQuestions { [weak self] (healthStatus, error) in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            // handle error
            if healthStatus == nil || error != nil {
                // hide activity indicator
                strongSelf.shouldShowLoadingIndicator.value = false
                // show error message
                strongSelf.isRequestQuestionsSuccessful.value = true
                return
            }

            // ??? Add sort order

            // cache response
            strongSelf.healthStatusData = healthStatus

            // prepare configurators
            strongSelf.configurators.append(NoSymptomsCellConfigurator(data:
                NoSymptomsCellModel(hasSymptoms: false,
                                    didTapCheckBox: { [weak self] isSelected in
                                        self?.didTapNoSymptomsButton(isActive: isSelected)
                })))

            healthStatus?.questions?.enumerated().forEach { (question) in
                strongSelf.configurators.append(
                    QuestionCellConfigurator(data:
                        QuestionCellModel(index: question.offset,
                                          title: question.element.questionTitle,
                                          isSymptomActive: question.element.isActive,
                                          didTapButton: { [weak self] hasSymptoms in
                                                self?.updateSymptoms(for: question.offset, hasSymptoms: hasSymptoms)
                                            }
                        )
                    )
                )
            }

            // hide activity indicator
            strongSelf.shouldShowLoadingIndicator.value = false
            // reload data
            strongSelf.isRequestQuestionsSuccessful.value = true
        }
    }

    func sendAnswers() {
        
        
        // show activity indicator
        shouldShowLoadingIndicator.value = true
        // !!! Not expected to be nil
        let answeredQuestions: [HealthStatusQuestion] = healthStatusData?.questions ?? []

        // TODO: Remove when it is no longer required
        // !!! Phone is still required in the API, though it can be obtained from the JWT
        // instead of storing the phone and passing it around, just decode it from JWT
        let decoder = JWTDecoder()
        let token = TokenStore.shared.token!
        let jwtBody: [String: Any] = decoder.decode(jwtToken: token)
        let phoneNumber = jwtBody["phoneNumber"] as! String

        QuestionnaireRepository().sendAnswers(answeredQuestions, for: phoneNumber) { [weak self] error in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            // hide activity indicator
            strongSelf.shouldShowLoadingIndicator.value = false
            // show error message or navigate to next screen
            strongSelf.isSendAnswersSuccessful.value = (error == nil)

        }
    }
    
}
