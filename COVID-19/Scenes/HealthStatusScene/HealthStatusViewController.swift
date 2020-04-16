//
//  SurveyViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import CoreLocation

class HealthStatusViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var submitButton: UIButton!

    // MARK: Actions

    @IBAction func submitButtonDidTap() {
        //Request Location Permissions
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        switch CLLocationManager.authorizationStatus() {
        case .restricted, .denied, .authorizedAlways, .authorizedWhenInUse: // authorized is deprecated
            viewModel.didTapSubmitButton()
        case .notDetermined:
            appDelegate?.requestLocationServicesAutorization()
        @unknown default:
            viewModel.didTapSubmitButton()
        }
    }

    // MARK: View Model

    var viewModel: HealthStatusViewModel!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindigs()
        // get data
        viewModel.getHealthStatusData()

        // TODO: Show it on button tap
        // TODO: Add auth completion handler
        // ??? Message title to be in Bulgarian (in Info.plist)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeLocationState),
                                               name: NSNotification.Name(rawValue: "didChooseLocationAccess"),
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // setup
        setupVC()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Notifications

    @objc
    private func didChangeLocationState() {
        viewModel.didTapSubmitButton()
    }

    // MARK: Setup Bindings

    private func setupBindigs() {
        bindReloadTableView()
        bindValidation()
        bindActivityIndicatorVisibility()
        bindRequestQuestionsResult()
        bindSendAnswersResult()
    }

    private func bindReloadTableView() {
        viewModel.shouldReloadData.bind { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.reloadCellIndexPath.bind { [weak self] indexPath in
            UIView.performWithoutAnimation {
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }

    private func bindValidation() {
        viewModel.isLeavingScreenAvailable.bind { [weak self] isLeavingScreenAvailable in
            guard let strongSelf = self else { return }
            if isLeavingScreenAvailable {
                strongSelf.viewModel.sendAnswers()
            } else {
                let alert = UIAlertController(title: "warning_label".localized(),
                                              message: "warning_msg".localized(),
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ok_label".localized(),
                                              style: UIAlertAction.Style.default,
                                              handler: nil))
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func bindActivityIndicatorVisibility() {
        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            guard let strongSelf = self else { return }
            if shouldShowLoadingIndicator {
                LoadingIndicatorManager.startActivityIndicator(.gray, in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }
    }

    private func bindRequestQuestionsResult() {
        viewModel.requestError.bind { [weak self] error in
            switch error {
            case .invalidToken:
                // TODO: Refactor - duplicated code
                let alert = UIAlertController.invalidTokenAlert { [weak self] in
                    self?.navigationDelegate?.navigateTo(step: .register)
                }
                self?.present(alert, animated: true, completion: nil)
            case .tooManyRequests(let reapeatAfter):
                let alert = UIAlertController.rateLimitExceededAlert(repeatAfterSeconds: reapeatAfter)
                self?.present(alert, animated: true, completion: nil)
            case .server, .general, .invalidEgnOrIdNumber:
                self?.showToast(message: "generic_error_msg".localized())
            }
        }
    }

    private func bindSendAnswersResult() {
        // fired only on success
        viewModel.isSendAnswersCompleted.bind { [weak self] _ in
            self?.navigateToNextViewController()
        }
    }

    // MARK: Setup UI

    private func setupVC() {
        title = "health_status".localized()

        tableView.tableFooterView = UIView()
        tableView.register(cellNames: "\(QuestionTableViewCell.self)",
            "\(NoSymptomsTableViewCell.self)")

        submitButton.backgroundColor = .healthBlue
        submitButton.layer.borderColor = UIColor.healthBlue?.cgColor

        submitButton.setTitle("save_changes_label".localized(), for: .normal)
    }

    // MARK: Navigation

    private func navigateToNextViewController() {
        navigationDelegate?.navigateTo(step: .completed)
    }

}

// MARK: UITableViewDelegate

extension HealthStatusViewController: UITableViewDelegate {

}

// MARK: UITableViewDataSource

extension HealthStatusViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configurator = viewModel.viewConfigurator(at: indexPath.item, in: indexPath.section) else { return UITableViewCell() }

        return tableView.configureCell(for: configurator, at: indexPath)
    }

}

// MARK: ToastViewPresentable

extension HealthStatusViewController: ToastViewPresentable {}
