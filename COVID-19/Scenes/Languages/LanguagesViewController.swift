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
    
    // MARK: Actions
    
    @IBAction func didTapConfirm(_ sender: Any) {
        
        if viewModel.isInitialFlow {
            if let indexPath = tableView.indexPathForSelectedRow {
                let languageData = viewModel.laguanges[indexPath.row]
                let locale = Locale(identifier: languageData.0)
                Localizer.shared.changeLocale(desiredLocale: locale) { [weak self] didChange, desiredLocale in
                    print(desiredLocale)
                    if didChange {
                        self?.setupUI()
                    }
                }
            }
            
           navigateToNextViewController()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !viewModel.isInitialFlow {
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
            let languageData = viewModel.laguanges[indexPath.row]
            let locale = Locale(identifier: languageData.0)
            Localizer.shared.changeLocale(desiredLocale: locale) { [weak self] didChange, desiredLocale in
                print(desiredLocale)
                if didChange {
                    self?.setupUI()
                }
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
        return viewModel.laguanges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        let languageData = viewModel.laguanges[indexPath.row];
        cell.textLabel?.text = languageData.1
        
        if Localizer.shared.getCurrentLocale().identifier == languageData.0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
}
