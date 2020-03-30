//
//  LanguagesViewController.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 30.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class LanguagesViewController: UIViewController, Navigateble {
    var navigationDelegate: NavigationDelegate?
    private let languagesViewControllerModel = LanguagesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        title = Constants.Strings.chooseLanguageTitle
    }
    

}



// MARK: UITableViewDelegate
extension LanguagesViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
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
        
        if Locale.current.currencyCode ?? "BGN" == languageData.0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
}
