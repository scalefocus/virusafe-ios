//
//  SurveyViewController.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit

class HealthStatusViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let viewModel = HealthStatusViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        
        viewModel.shouldReloadData.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.reloadCellIndexPath.bind { [weak self] indexPath in
            UIView.performWithoutAnimation {
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        viewModel.isLeavingScreenAvailable.bind { [weak self] isLeavingScreenAvailable in
            guard let strongSelf = self else { return }
            if isLeavingScreenAvailable {
                strongSelf.navigateToConfirmationViewController()
            } else {
                let alert = UIAlertController(title: "Внимание", message: "За да запазите промените е нужно да попълните всички точки от въпросника", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Добре", style: UIAlertAction.Style.default, handler: nil))
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
        
        viewModel.getHealthStatusData()
    }
    
    private func setupVC() {
        title = "Здравен статус"
        tableView.tableFooterView = UIView()
        tableView.register(cellNames: "\(QuestionTableViewCell.self)",
            "\(NoSymptomsTableViewCell.self)",
            "\(SubmitTableViewCell.self)")
    }

    // MARK: Navigation

    private func navigateToConfirmationViewController() {
        let confirmationViewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "\(ConfirmationViewController.self)")
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }

}

extension HealthStatusViewController: UITableViewDelegate {
    
}

extension HealthStatusViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configurator = viewModel.viewConfigurator(at: indexPath.item, in: indexPath.section) else { return UITableViewCell() }
        
        return tableView.configureCell(for: configurator, at: indexPath)
    }
    
}
