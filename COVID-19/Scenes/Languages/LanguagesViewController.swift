//
//  LanguagesViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 30.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import UpnetixLocalizer

class LanguagesViewController: UIViewController {
    
    // MARK: View Model
    
    private let languagesViewControllerModel = LanguagesViewModel()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    private func setupUI() {
        title = "select_language".localized()
    }
    

}



// MARK: UITableViewDelegate
extension LanguagesViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let languageData = languagesViewControllerModel.laguanges[indexPath.row]
        let locale = Locale(identifier: languageData.0)
        Localizer.shared.changeLocale(desiredLocale: locale) { [weak self] didChange, desiredLocale in
            print(desiredLocale)
            if didChange {
                self?.setupUI()
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
        return languagesViewControllerModel.laguanges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        let languageData = languagesViewControllerModel.laguanges[indexPath.row];
        cell.textLabel?.text = languageData.1
        
        if Localizer.shared.getCurrentLocale().identifier == languageData.0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
}
