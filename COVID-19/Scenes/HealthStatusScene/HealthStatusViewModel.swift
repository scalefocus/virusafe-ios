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
    
    private var configurators: [ViewConfigurator] = []
    private var healthStatusData: HealthStatus?
    let shouldReloadData = Observable<Bool>()
    let isLeavingScreenAvailable = Observable<Bool>()
    let reloadCellIndexPath = Observable<IndexPath>()
    
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
    
    func getHealthStatusData() {
        QuestionnaireRepository().requestQuestions { [weak self] (healthStatus, error) in
            // TODO: Handle error
            // ??? Add sort order
            guard let strongSelf = self else { return }
            strongSelf.healthStatusData = healthStatus

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

            strongSelf.shouldReloadData.value = true
        }
    }

    func sendAnswers(_ completion: @escaping (() -> Void)) {
        // !!! Not expected to be nil
        let answeredQuestions: [HealthStatusQuestion] = healthStatusData?.questions ?? []
        // TODO: Replace this hardcoded phone number
        QuestionnaireRepository().sendAnswers(answeredQuestions, for: "1234124124") { error in
            // TODO: Handle error
            completion()
        }
    }
    
}
