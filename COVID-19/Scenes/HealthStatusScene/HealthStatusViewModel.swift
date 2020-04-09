//
//  HealthStatusViewModel.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import TwoWayBondage
import UpnetixLocalizer

protocol HealthStatusViewModelDelegate: class {
    func sendHealtStatus(_ request: AnswersRequest,
                         shouldDelayRequest: Bool,
                         with completion: @escaping SendAnswersCompletion)
}

class HealthStatusViewModel {

    private weak var delegate: HealthStatusViewModelDelegate?

    private var questionnaireRepository: QuestionnaireRepository
    private var firstLaunchCheckRepository: AppLaunchRepository

    init(questionnaireRepository: QuestionnaireRepository,
         firstLaunchCheckRepository: AppLaunchRepository,
         delegate: HealthStatusViewModelDelegate) {
        self.questionnaireRepository = questionnaireRepository
        self.firstLaunchCheckRepository = firstLaunchCheckRepository
        self.delegate = delegate
    }
    
    typealias NoSymptomsCellConfigurator = BaseViewConfigurator<NoSymptomsTableViewCell>
    typealias QuestionCellConfigurator = BaseViewConfigurator<QuestionTableViewCell>

    // state
    
    private var configurators: [ViewConfigurator] = []
    private var healthStatusData: HealthStatus?

    // Observables

    var isInitialFlow: Bool {
        return !firstLaunchCheckRepository.isAppLaunchedBefore
    }

    let shouldReloadData = Observable<Bool>()
    let isLeavingScreenAvailable = Observable<Bool>()
    let reloadCellIndexPath = Observable<IndexPath>()
    let shouldShowLoadingIndicator = Observable<Bool>()
    let requestError = Observable<ApiError>()
    let isSendAnswersCompleted = Observable<Bool>()

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
        healthStatusData?.questions?[index - 1].isActive = hasSymptoms
        (configurators[safeAt: index] as? QuestionCellConfigurator)?.data.isSymptomActive = hasSymptoms
        reloadCellIndexPath.value = IndexPath(item: index, section: 0)

        (configurators[safeAt: 0] as? NoSymptomsCellConfigurator)?.data.hasSymptoms = areAllFieldsNegative
        reloadCellIndexPath.value = IndexPath(item: 0, section: 0)
    }

    // TODO: Refactor - split this function it is too long
    func getHealthStatusData() {
        // show activity indicator
        shouldShowLoadingIndicator.value = true

        questionnaireRepository.requestQuestions(with: LanguageHelper.shared.savedLocale) { [weak self] result in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            defer {
                // hide activity indicator
                strongSelf.shouldShowLoadingIndicator.value = false
            }
            switch result {
                case .success(let healthStatus):
                    // cache response
                    // ??? Add sort order
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
                                                    self?.updateSymptoms(for: question.offset + 1, hasSymptoms: hasSymptoms)
                                    }
                                )
                            )
                        )
                    }
                    // reload table
                    strongSelf.shouldReloadData.value = true
                case .failure(let reason):
                    strongSelf.requestError.value = reason
            }
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

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let location = appDelegate.currentLocation()

        // Make BE happy if location could not be obtained
        let request = AnswersRequest(
            answers: answeredQuestions,
            phoneNumber: phoneNumber,
            latitude: location?.latitude ?? 0,
            longitude: location?.longitude ?? 0)

        delegate?.sendHealtStatus(request, shouldDelayRequest: false) { [weak self] result in
            // if we're gone do nothing
            guard let strongSelf = self else { return }
            // hide activity indicator
            strongSelf.shouldShowLoadingIndicator.value = false
            switch result {
                case .success:
                    strongSelf.isSendAnswersCompleted.value = true
                case .failure(let reason):
                    strongSelf.requestError.value = reason
            }
        }
    }
    
}
