//
//  AppFlowManager.swift
//  ViruSafe
//
//  Created by Aleksandar Sergeev Petrov on 28.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
//import NetworkKit

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
    case languages(isInitial: Bool)
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
        case initialLanguages
        case languages

        case pop
    }

    private var navigationController: UINavigationController

    private let defaultAcceptButtonVisibility = true

    private var registrationRepository = RegistrationRepository()
    private var termsAndConditionsRepository = TermsAndConditionsRepository()
    private var firstLaunchCheckRepository = AppLaunchRepository()
    private var questionnaireRepository = QuestionnaireRepository()
    private var personalInformationRepository = PersonalInformationRepository()

    private var answersRequestStore: DelayedAnswersRequestStore?

    // MARK: Object lifecyle

    init(window: UIWindow) {
        // !!! Only Splash Screen is in Main
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
            case (.ready, .home), (.healthStatus, .home), (.success, .home), (.registerConfirm, .home), (.personalInformation, .home):
                return true
            case (.home, .healthStatus), (.personalInformation, .healthStatus):
                return true
            case (.healthStatus, .success), (.personalInformation, .success):
                return true
            case (.register, .registerConfirm):
                return true
            case (.initialLanguages, .initialAbout):
                return true
            case (.ready, .initialLanguages):
                return true
            case (.home, .personalInformation), (.registerConfirm, .personalInformation):
                return true
            case (.home, .languages):
                return true
            default:
                return false
        }
    }

    func didTransition(from oldState: StateType, to newState: StateType) {
        switch (oldState, newState) {
            case (.ready, .home), (.healthStatus, .home), (.success, .home), (.registerConfirm, .home), (.personalInformation, .home):
                previousStatesStack = [newState]
                setHomeAsRootViewController()
            case (_, .register):
                previousStatesStack = [newState]
                setRegisterAsRootViewController()
            case (.home, .healthStatus), (.personalInformation, .healthStatus):
                previousStatesStack.append(newState)
                navigateToHealthStatusViewController()
            case (.healthStatus, .success), (.personalInformation, .success):
                previousStatesStack.append(newState)
                navigateToConfirmationViewController()
            case (.register, .registerConfirm):
                previousStatesStack.append(newState)
                navigateToRegistrationConfirmation()
            case (.initialLanguages, .initialAbout):
                previousStatesStack = [newState]
                navigateToWebViewController(source: .about, isRoot: true)
            case (.home, .personalInformation):
                previousStatesStack.append(newState)
                navigateToPersonalInformationViewController(shouldNavigateNextToHealthStatus: false)
            case (.registerConfirm, .personalInformation):
                previousStatesStack.append(newState)
                navigateToPersonalInformationViewController(shouldNavigateNextToHealthStatus: true)
            case (.home, .languages):
                previousStatesStack.append(newState)
                navigateToLanguagesViewController()
            case (.ready, .initialLanguages):
                previousStatesStack.append(newState)
                navigateToLanguagesViewController()
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
            case .languages(let isInitial):
                if isInitial {
                    stateMachine.state = .initialLanguages
                } else {
                    stateMachine.state = .languages
                }
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

        let storyboard = UIStoryboard(name: "Home", bundle: nil)
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

        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let registerViewController = storyboard.instantiateViewController(withIdentifier: "\(RegistrationViewController.self)")
            as! RegistrationViewController // !!! Force unwrap
        let registrationViewModel = RegistrationViewModel(registrationRepository: registrationRepository,
                                                          termsAndConditionsRepository: termsAndConditionsRepository)
        registerViewController.viewModel = registrationViewModel
        registerViewController.navigationDelegate = self
        navigationController.setRoot(viewController: registerViewController)
    }

    private func navigateToTermsAndConditions() {
        let storyboard = UIStoryboard(name: "TnC", bundle: nil)
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
        let storyboard = UIStoryboard(name: "HealthStatus", bundle: nil)
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
    
    private func navigateToLanguagesViewController() {
        let storyboard = UIStoryboard(name: "Languages", bundle: nil)
        let languagesViewController = storyboard
            .instantiateViewController(withIdentifier: "\(LanguagesViewController.self)")
            as! LanguagesViewController // !!! Force unwrap
        
        languagesViewController.title = "select_language".localized()
        languagesViewController.viewModel = LanguagesViewModel.init(firstLaunchCheckRepository: firstLaunchCheckRepository)
        languagesViewController.navigationDelegate = self

        // TODO: Use firstLaunchCheckRepository
        if !languagesViewController.viewModel.isInitialFlow {
            navigationController.push(viewController: languagesViewController)
            setupBackButton(viewController: languagesViewController)
        } else {
            navigationController.setNavigationBarHidden(false, animated: false)
            navigationController.setRoot(viewController: languagesViewController)
        }
    }
    
    private func navigateToConfirmationViewController() {
        let confirmationViewController =
            UIStoryboard(name: "Confirmation", bundle: nil)
                .instantiateViewController(withIdentifier: "\(ConfirmationViewController.self)")
        as! ConfirmationViewController // !!! Force unwrap
        confirmationViewController.navigationDelegate = self
        navigationController.push(viewController: confirmationViewController)
    }

    private func navigateToRegistrationConfirmation() {
        guard let registrationConfirmationVC =
            UIStoryboard(name: "Registration", bundle: nil)
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

    private func navigateToPersonalInformationViewController(shouldNavigateNextToHealthStatus: Bool) {
        guard let personalInformationViewController =
            UIStoryboard(name: "PersonalInformation", bundle: nil)
                .instantiateViewController(withIdentifier: "\(PersonalInformationViewController.self)")
                as? PersonalInformationViewController else {
                    assertionFailure("PersonalInformationViewController is not found")
                    return
        }
        let viewModel = PersonalInformationViewModel(firstLaunchCheckRepository: firstLaunchCheckRepository,
                                                     personalInformationRepository: personalInformationRepository,
                                                     shouldNavigateNextToHealthStatus: shouldNavigateNextToHealthStatus)
        personalInformationViewController.navigationDelegate = self
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
            title: "continue_label".localized(),
            style: .plain,
            target: self,
            action: #selector(AppFlowManager.navigateToNextControllerFromInitialAbout))
        viewController.navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc
    private func navigateToNextControllerFromInitialAbout(sender: UIBarButtonItem) {
        navigateTo(step: .register)
    }

    // Navigate back

    private func setupBackButton(viewController: UIViewController) {
        navigationController.navigationBar.tintColor = UIColor.healthBlue
        viewController.navigationItem.leftBarButtonItem?.tintColor = UIColor.healthBlue
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back_text".localized(),
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(AppFlowManager.back(sender:)))
    }
    
    private func setupBackButtonNoStateMachine(viewController: UIViewController) {
        navigationController.navigationBar.tintColor = UIColor.healthBlue
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back_text".localized(),
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
