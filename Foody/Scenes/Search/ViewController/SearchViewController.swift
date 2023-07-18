//
//  SearchVC.swift
//  Foody
//
//  Created by halil yılmaz on 23.06.2023.
//

import UIKit
import SnapKit


class SearchViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: SearchResultVC())
    
    var viewModel: SearchViewModel = SearchViewModel()
    
    private let tvMain: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    let searchButton = CustomButton(title: "Ara", fontSize: .med, backgroundColor: .systemBlue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true

        definesPresentationContext = true
        tvMain.delegate = self
        tvMain.dataSource = self
        
        setupUI()
        registerCell()
        
        if let searchResultVC = searchController.searchResultsController as? SearchResultVC {
            viewModel.delegate = searchResultVC
        }
    }
    
    func setupUI() {
        view.addSubview(tvMain)
        view.addSubview(searchButton)
        
        tvMain.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(tvMain.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-100)
            make.height.equalTo(46)
        }
        
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
    }
    
    @objc func didTapSearchButton(){
        
        let searchByMaterialsVC = SearchByMaterialsVC()
        searchByMaterialsVC.keywordsList = self.viewModel.selectedItems
        let navigationController = UINavigationController(rootViewController: searchByMaterialsVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func registerCell(){
        tvMain.register(MaterialListCell.self, forCellReuseIdentifier: MaterialListCell.identifier)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.materialsTool.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.materialsTool[section].learnType
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.materialsTool[section].list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MaterialListCell.identifier, for: indexPath) as! MaterialListCell
        cell.sectionLabel.text = viewModel.materialsTool[indexPath.section].list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .gray.withAlphaComponent(0.9)
        view.layer.cornerRadius = 6
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerCurve = .circular
        view.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .secondarySystemBackground
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let selectedValue = viewModel.materialsTool[indexPath.section].list[indexPath.row]
        
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            if let index = viewModel.selectedItems.firstIndex(of: selectedValue) {
                viewModel.selectedItems.remove(at: index)
            }
        } else {
            cell?.accessoryType = .checkmark
            if !viewModel.selectedItems.contains(selectedValue) {
                viewModel.selectedItems.append(selectedValue)
            }
        }
        
        print(viewModel.selectedItems)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
            guard let text = searchController.searchBar.text else {
                return
            }
            
        viewModel.searchRecipes(withKeyword: text)
        }
}

