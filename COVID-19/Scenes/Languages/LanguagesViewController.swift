//
//  LanguagesViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 30.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import UpnetixLocalizer

class LanguagesViewController: UIViewController, Navigateble {
    
    // MARK: Navigateble

    weak var navigationDelegate: NavigationDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Model
    
    var viewModel:LanguagesViewModel!
    
    // MARK: Bind

    private func setupBindings() {
        viewModel.laguanges.bind { [weak self] languages in
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
        
        guard viewModel.isInitialFlow == true else { return }
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
        let languageData = viewModel.laguanges.value![indexPath.row]
        let locale = Locale(identifier: languageData.0)
        Localizer.shared.changeLocale(desiredLocale: locale) { [weak self] didChange, desiredLocale in
            print(desiredLocale)
            if didChange {
                self?.setupUI()
                UserDefaults.standard.setValue(languageData.0, forKeyPath: "userLocale")
                UserDefaults.standard.synchronize()
                self?.navigateToNextViewController()
            }

            // TODO: Handle error
        }
    
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getAvailableLanguages()
        setupBindings()
        
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

        // TODO: Change back button if exists

        // TODO: Refactor to move this side effect
        StaticContentPage.shared.url = "url_about_covid".localized()
        AppInfoPage.shared.url = "url_virusafe_why".localized()

        // back button
        let item = navigationItem.leftBarButtonItem
        let button = item?.customView as? UIButton
        button?.setTitleColor(.healthBlue, for: .normal)
        button?.setTitle("back_text".localized(), for: .normal)
        button?.sizeToFit()
    }
    
    private func navigateToNextViewController() {
        navigationDelegate?.navigateTo(step: .about(isInitial: viewModel.isInitialFlow))
    }

}

// MARK: UITableViewDelegate
extension LanguagesViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        if !viewModel.isInitialFlow {
            let languageData = viewModel.laguanges.value![indexPath.row]
            let locale = Locale(identifier: languageData.0)
            Localizer.shared.changeLocale(desiredLocale: locale) { [weak self] didChange, desiredLocale in
                print(desiredLocale)
                if didChange {
                    self?.setupUI()
                    UserDefaults.standard.setValue(languageData.0, forKeyPath: "userLocale")
                }
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
        let languageData = viewModel.laguanges.value![indexPath.row];
        cell.textLabel?.text = languageData.1
        
        if Localizer.shared.getCurrentLocale().identifier == languageData.0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
}
