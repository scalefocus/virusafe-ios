//
//  LanguagesViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 30.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import Flex

class LanguagesViewController: UIViewController, Navigateble {

    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?

    // MARK: Outlets

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    // MARK: View Model

    var viewModel: LanguagesViewModel!

    // MARK: Bind

    private func setupBindings() {
        viewModel.laguanges.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.shouldShowLoadingIndicator.bind { [weak self] shouldShowLoadingIndicator in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                if shouldShowLoadingIndicator {
                    LoadingIndicatorManager.startActivityIndicator(.gray, in: strongSelf.view)
                } else {
                    LoadingIndicatorManager.stopActivityIndicator(in: strongSelf.view)
                }
            }
        }
    }

    // MARK: Actions

    @IBAction func didTapConfirm(_ sender: Any) {
        // !!! This button should be hidden if we're not here from the initail flow
        guard viewModel.isInitialFlow == true else { return }
        self.navigateToNextViewController()
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getAvailableLanguages()
        setupBindings()
        tableView.tableFooterView = UIView() // to remove separators that we dont need

        if viewModel.isInitialFlow {
            confirmButton.isHidden = false
        } else {
            confirmButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupUI()
    }

    private func setupUI() {
        title = "select_language".localized()

        confirmButton.backgroundColor = .healthBlue
        confirmButton.setTitle("confirm_label".localized(), for: .normal)

        StaticContentPage.shared.url = "url_about_covid".localized()
        AppInfoPage.shared.url = "url_virusafe_why".localized()

        // back button
        let item = navigationItem.leftBarButtonItem
        let button = item?.customView as? UIButton
        button?.setTitleColor(.healthBlue, for: .normal)
        button?.setTitle("back_text".localized(), for: .normal)
        button?.sizeToFit()
        navigationItem.leftBarButtonItem?.title = "back_text".localized()
    }

    private func navigateToNextViewController() {
        navigationDelegate?.navigateTo(step: .about(isInitial: viewModel.isInitialFlow))
    }

}

// MARK: UITableViewDelegate
extension LanguagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark

        guard let languageData = viewModel.laguanges.value?[indexPath.row] else { return }
        let locale = Locale(identifier: languageData.0)
        Flex.shared.changeLocale(desiredLocale: locale) { [weak self] didChange, desiredLocale in
            print(desiredLocale)
            if didChange {
                self?.setupUI()
                LanguageHelper.shared.savedLocale = languageData.0
            } else {
                // TODO: Handle error
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }

}

// MARK: UITableViewDataSource
extension LanguagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.laguanges.value?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        guard let languageData = viewModel.laguanges.value?[indexPath.row] else { return cell }
        cell.textLabel?.text = languageData.0.getFlag + " " + languageData.1

        if Flex.shared.getCurrentLocale().identifier == languageData.0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

}

extension String {
    var getFlag: String {
        let base: UInt32 = 127397
        var unicodeString = ""
        var current = self

        if self.count > 2 && self.contains("-") {
            current = String(self.split(separator: "-")[safeAt: 1] ?? "")
        }

        // quick fix for albanian flag
        if self == "sq" {
            current = "al"
        }

        for scalar in current.uppercased().unicodeScalars {
            guard let unicode = UnicodeScalar(base + scalar.value) else { return unicodeString }
            unicodeString.unicodeScalars.append(unicode)
        }
        return unicodeString
    }
}
