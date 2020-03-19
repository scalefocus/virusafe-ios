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
        
        viewModel.shouldReloadData.bind { [weak self] (_) in
            self?.tableView.reloadData()
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
