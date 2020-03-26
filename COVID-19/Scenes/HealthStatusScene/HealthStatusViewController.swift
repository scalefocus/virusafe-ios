//
//  SurveyViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class HealthStatusViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var submitButton: UIButton!

    // MARK: Actions

    @IBAction func submitButtonDidTap() {
        //Request Location Permissions
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.requestLocationServicesAutorization()
    }

    // MARK: View Model

    private let viewModel = HealthStatusViewModel()

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup
        setupVC()
        setupBindigs()
        // get data
        viewModel.getHealthStatusData()
        
        // TODO: Show it on button tap
        // TODO: Add auth completion handler
        // ??? Message title to be in Bulgarian (in Info.plist)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeLocationState), name: NSNotification.Name(rawValue: "didChooseLocationAccess"), object: nil)
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
                let alert = UIAlertController(title: Constants.Strings.generalWarningText,
                                              message: Constants.Strings.healthStatusPopulateAllFiendsErrorText,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: Constants.Strings.genaralAgreedText,
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
                LoadingIndicatorManager.startActivityIndicator(.whiteLarge, in: strongSelf.view)
            } else {
                LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
            }
        }
    }

    private func bindRequestQuestionsResult() {
        viewModel.requestError.bind { [weak self] error in
            switch error {
                case .tooManyRequests:
                    self?.showToast(message: Constants.Strings.healthStatusTooManyRequestsErrorText)
                case .server, .general:
                    self?.showToast(message: Constants.Strings.healthStatusUnknownErrorText)
            }
        }
    }

    private func bindSendAnswersResult() {
        // fired only on success
        viewModel.isSendAnswersCompleted.bind { [weak self] _ in
            self?.navigateToConfirmationViewController()
        }
    }

    // MARK: Setup UI
    
    private func setupVC() {
        title = Constants.Strings.healthStatusHealthStatuText

        tableView.tableFooterView = UIView()
        tableView.register(cellNames: "\(QuestionTableViewCell.self)",
            "\(NoSymptomsTableViewCell.self)")

        submitButton.backgroundColor = .healthBlue
        submitButton.layer.borderColor = UIColor.healthBlue?.cgColor
    }

    // MARK: Navigation

    private func navigateToConfirmationViewController() {
        let confirmationViewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(ConfirmationViewController.self)")
        navigationController?.pushViewController(confirmationViewController, animated: true)
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
