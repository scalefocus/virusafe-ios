//
//  AppFlowManager.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

// TODO: Refactor

enum NavigationStep {
    case register
    case registerConfirm
    case home
    case healthStatus
    case termsAndConditions
    case web(source: Source)
    case completed
    case about(isInitial: Bool)
    case personalInformation
}

protocol NavigationDelegate: class {
    func navigateTo(step: NavigationStep)
}

protocol Navigateble {
    var navigationDelegate: NavigationDelegate? { get }
}

final class AppFlowManager: StateMachineDelegateProtocol {
    enum FlowState {
        case ready // splash
        case register
        case registerConfirm
        case home
        case healthStatus
        case personalInformation
        case success // confirm
        case initialAbout

        case pop
    }

    private var navigationController: UINavigationController

    private let defaultAcceptButtonVisibility = true

    private var registrationRepository = RegistrationRepository()
    private var termsAndConditionsRepository = TermsAndConditionsRepository()
    private var firstLaunchCheckRepository = AppLaunchRepository()
    private var questionnaireRepository = QuestionnaireRepository()

    private var answersRequestStore: DelayedAnswersRequestStore?

    // MARK: Object lifecyle

    init(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard
            .instantiateInitialViewController()! // !!! Force unwrap
            as!  SplashViewController
        navigationController = UINavigationController(rootViewController: initialViewController)
//        navigationController.delegate = self
        initialViewController.navigationDelegate = self
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: StateMachineDelegateProtocol

    private var previousStatesStack: [StateType] = []

    lazy var stateMachine: StateMachine<AppFlowManager> = {
        return StateMachine(initialState: .ready, delegate: self)
    }()

    typealias StateType = FlowState

    func shouldTransition(from oldState: StateType, to newState: StateType) -> Bool {
        switch (oldState, newState) {
            case (_, .pop), (.pop, _):
                return true
            case (_, .register):
                return true
            case (.ready, .home), (.healthStatus, .home), (.success, .home), (.registerConfirm, .home):
                return true
            case (.home, .healthStatus), (.initialAbout, .healthStatus):
                return true
            case (.healthStatus, .success), (.personalInformation, .success):
                return true
            case (.register, .registerConfirm):
                return true
            case (.registerConfirm, .initialAbout):
                return true
            case (.home, .personalInformation), (.healthStatus, .personalInformation):
                return true
            default:
                return false
        }
    }

    func didTransition(from oldState: StateType, to newState: StateType) {
        switch (oldState, newState) {
            case (.ready, .home), (.healthStatus, .home), (.success, .home), (.registerConfirm, .home):
                previousStatesStack = [newState]
                setHomeAsRootViewController()
            case (_, .register):
                previousStatesStack = [newState]
                setRegisterAsRootViewController()
            case (.home, .healthStatus), (.initialAbout, .healthStatus):
                previousStatesStack.append(newState)
                navigateToHealthStatusViewController()
            case (.healthStatus, .success), (.personalInformation, .success):
                previousStatesStack.append(newState)
                navigateToConfirmationViewController()
            case (.register, .registerConfirm):
                previousStatesStack.append(newState)
                navigateToRegistrationConfirmation()
            case (.registerConfirm, .initialAbout):
                previousStatesStack = [newState]
                navigateToWebViewController(source: .about, isRoot: true)
            case (.home, .personalInformation), (.healthStatus, .personalInformation):
                previousStatesStack.append(newState)
                navigateToPersonalInformationViewController()
            default:
                break
        }
    }
}

// MARK: NavigationDelegate

// TODO: This should be moved in Router class
extension AppFlowManager: NavigationDelegate {
    func navigateTo(step: NavigationStep) {
        switch step {
            case .home:
                stateMachine.state = .home
            case .register:
                stateMachine.state = .register
            case .registerConfirm:
                stateMachine.state = .registerConfirm
            case .termsAndConditions:
                // !!! This doesn't affect machine's state
                navigateToTermsAndConditions()
            case .web(let source):
                // !!! This doesn't affect machine's state
                navigateToWebViewController(source: source, isRoot: false)
            case .healthStatus:
                stateMachine.state = .healthStatus
            case .completed:
                stateMachine.state = .success
            case .about(let isInitial):
                if isInitial {
                    stateMachine.state = .initialAbout
                } else {
                    // !!! This doesn't affect machine's state
                    navigateToWebViewController(source: .about, isRoot: false)
                }
            case .personalInformation:
                stateMachine.state = .personalInformation
            @unknown default:
                assertionFailure("Unhandled navigation step: \(step)")
        }
    }

    // Routing

    private func setHomeAsRootViewController() {
        if navigationController.viewControllers.first is HomeViewController {
            navigationController.popToRoot()
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "\(HomeViewController.self)")
            as! HomeViewController // !!! Force unwrap
        homeViewController.navigationDelegate = self
        navigationController.setRoot(viewController: homeViewController)
    }

    private func setRegisterAsRootViewController() {
        if navigationController.viewControllers.first is RegistrationViewController {
            navigationController.popToRoot()
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerViewController = storyboard.instantiateViewController(withIdentifier: "\(RegistrationViewController.self)")
            as! RegistrationViewController // !!! Force unwrap
        let registrationViewModel = RegistrationViewModel(registrationRepository: registrationRepository,
                                                          termsAndConditionsRepository: termsAndConditionsRepository)
        registerViewController.viewModel = registrationViewModel
        registerViewController.navigationDelegate = self
        navigationController.setRoot(viewController: registerViewController)
    }

    private func navigateToTermsAndConditions() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tncViewController = storyboard
            .instantiateViewController(withIdentifier: "\(TermsAndConditionsViewController.self)")
            as? TermsAndConditionsViewController else {
                assertionFailure("TermsAndConditionsViewController is not found")
                return
        }
        tncViewController.viewModel = TermsAndConditionsViewModel(repository: termsAndConditionsRepository)
        tncViewController.userResponseHandler = { [weak self] in
            self?.navigationController.pop()
        }
        navigationController.push(viewController: tncViewController)
        setupBackButtonNoStateMachine(viewController: tncViewController)
    }

    private func navigateToHealthStatusViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let healthStatusViewController = storyboard
            .instantiateViewController(withIdentifier: "\(HealthStatusViewController.self)")
            as! HealthStatusViewController // !!! Force unwrap
        let viewModel = HealthStatusViewModel(questionnaireRepository: questionnaireRepository,
                                              firstLaunchCheckRepository: firstLaunchCheckRepository,
                                              delegate: self)
        healthStatusViewController.viewModel = viewModel

        healthStatusViewController.navigationDelegate = self

        navigationController.push(viewController: healthStatusViewController)
        setupBackButton(viewController: healthStatusViewController)
    }

    private func navigateToConfirmationViewController() {
        let confirmationViewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(ConfirmationViewController.self)")
        as! ConfirmationViewController // !!! Force unwrap
        confirmationViewController.navigationDelegate = self
        navigationController.push(viewController: confirmationViewController)
    }

    private func navigateToRegistrationConfirmation() {
        guard let registrationConfirmationVC =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(RegistrationConfirmationViewController.self)")
                as? RegistrationConfirmationViewController else {
                    assertionFailure("RegistrationConfirmationViewController is not found")
                    return
        }
        registrationConfirmationVC.navigationDelegate = self
        registrationConfirmationVC.viewModel =
            RegistrationConfirmationViewModel(registrationRepository: registrationRepository,
                                              firstLaunchCheckRepository: firstLaunchCheckRepository)

        navigationController.push(viewController: registrationConfirmationVC)
        setupBackButton(viewController: registrationConfirmationVC)
    }

    private func navigateToPersonalInformationViewController() {
        guard let personalInformationViewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(PersonalInformationViewController.self)")
                as? PersonalInformationViewController else {
                    assertionFailure("PersonalInformationViewController is not found")
                    return
        }
        let viewModel = PersonalInformationViewModel(firstLaunchCheckRepository: firstLaunchCheckRepository,
                                                     delegate: self)
        personalInformationViewController.viewModel = viewModel
        navigationController.push(viewController: personalInformationViewController)
        setupBackButton(viewController: personalInformationViewController)
    }

    private func navigateToWebViewController(source: Source, isRoot: Bool) {
        let storyboard = UIStoryboard(name: "WebView", bundle: nil)
        let webViewController = storyboard
            .instantiateViewController(withIdentifier: "\(WebViewController.self)")
            as! WebViewController // !!! Force unwrap
        if isRoot {
            navigationController.setRoot(viewController: webViewController)
            setupAboutNextButton(viewController: webViewController)
        } else {
            navigationController.push(viewController: webViewController)
            setupBackButtonNoStateMachine(viewController: webViewController)
        }

        webViewController.load(source: source)
    }

    private func setupAboutNextButton(viewController: UIViewController) {
        let rightBarButtonItem = UIBarButtonItem(
            title: Constants.Strings.newVersionAlertOkButtonTitle,
            style: .plain,
            target: self,
            action: #selector(AppFlowManager.showHealthStatusFromAbout))
        viewController.navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc
    private func showHealthStatusFromAbout(sender: UIBarButtonItem) {
        navigateTo(step: .healthStatus)
    }

    // Navigate back

    private func setupBackButton(viewController: UIViewController) {
        viewController.navigationItem.hidesBackButton = true
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Constants.Strings.generalBackText,
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(AppFlowManager.back(sender:)))
    }
    private func setupBackButtonNoStateMachine(viewController: UIViewController) {
        viewController.navigationItem.hidesBackButton = true
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Constants.Strings.generalBackText,
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(AppFlowManager.backNoStateMachine(sender:)))
    }

    @objc
    private func back(sender: UIBarButtonItem) {
        previousStatesStack.removeLast()
        let newState = previousStatesStack.last ?? .ready
        stateMachine.state = .pop
        stateMachine.state = newState
        navigationController.pop()
    }

    @objc
    private func backNoStateMachine(sender: UIBarButtonItem) {
        navigationController.pop()
    }
}

// MARK: Delayed Health Status Request Helpers

struct DelayedAnswersRequestStore {
    var request: AnswersRequest
}

struct AnswersRequest {
    var answers: [HealthStatusQuestion]
    var phoneNumber: String
    var latitude: Double
    var longitude: Double
}

struct PersonalInformationRequest {
    var personalNumber: String // egn/id/pasport number
    var phoneNumber: String?
    // TODO: Others
}

// MARK: HealthStatusViewModelDelegate

extension AppFlowManager: HealthStatusViewModelDelegate {
    func sendHealtStatus(_ request: AnswersRequest,
                         shouldDelayRequest: Bool,
                         with completion: @escaping SendAnswersCompletion) {
        if shouldDelayRequest {
            answersRequestStore = DelayedAnswersRequestStore(request: request)
            completion(.success(Void()))
        } else {
            sendHealtStatus(request, with: completion)
        }
    }

    private func sendHealtStatus(_ request: AnswersRequest,
                                 with completion: @escaping SendAnswersCompletion) {
        questionnaireRepository
            .sendAnswers(request.answers,
                         for: request.phoneNumber,
                         at: request.latitude,
                         longitude: request.longitude,
                         with: completion)
    }
}

// MARK: PersonalInformationViewModelDelegate

extension AppFlowManager: PersonalInformationViewModelDelegate {
    func sendDelayedAnswers(with completion: @escaping SendAnswersCompletion) {
        guard let answersRequestStore = self.answersRequestStore else {
            completion(.success(Void()))
            return
        }
        firstLaunchCheckRepository.isAppLaunchedBefore = true
        sendHealtStatus(answersRequestStore.request, with: completion)
    }

    func sendPersonalInformation(_ request: PersonalInformationRequest,
                                 with completion: @escaping ((AuthoriseMobileNumberResult) -> Void)) {
        registrationRepository.authorisePersonalNumber(personalNumberNumber: request.personalNumber,
                                                       completion: completion)
    }
}

// MARK: UINavigationController Transition Animations

private extension UINavigationController {

    func setRoot(viewController vc: UIViewController,
                 transitionType type: CATransitionType = .fade,
                 duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.setViewControllers([vc], animated: false)
    }

    func popToRoot() {
        self.popToRootViewController(animated: true)
    }

    func pop() {
        self.popViewController(animated: true)
    }

    func push(viewController vc: UIViewController) {
        self.pushViewController(vc, animated: true)
    }

//    func popToRoot(transitionType type: CATransitionType = .fade,
//                   duration: CFTimeInterval = 0.3) {
//        self.addTransition(transitionType: type, duration: duration)
//        self.popToRootViewController(animated: false)
//    }
//    /**
//     Pop current view controller to previous view controller.
//
//     - parameter type:     transition animation type.
//     - parameter duration: transition animation duration.
//     */
//    func pop(transitionType type: CATransitionType = .fade,
//             duration: CFTimeInterval = 0.3) {
//        self.addTransition(transitionType: type, duration: duration)
//        self.popViewController(animated: false)
//    }

//    /**
//     Push a new view controller on the view controllers's stack.
//
//     - parameter vc:       view controller to push.
//     - parameter type:     transition animation type.
//     - parameter duration: transition animation duration.
//     */
//    func push(viewController vc: UIViewController,
//              transitionType type: CATransitionType = .fade,
//              duration: CFTimeInterval = 0.3) {
//        self.addTransition(transitionType: type, duration: duration)
//        self.pushViewController(vc, animated: false)
//    }

    private func addTransition(transitionType type: CATransitionType = .fade,
                               duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }

}