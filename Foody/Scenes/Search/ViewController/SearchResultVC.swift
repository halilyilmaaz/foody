//
//  SearchResultVC.swift
//  Foody
//
//  Created by halil yılmaz on 24.06.2023.
//
import UIKit
import SnapKit

class SearchResultVC: UIViewController {
    
    var viewModel: SearchViewModel = SearchViewModel()
    
    var searchResults: [HomeRecipeCardModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tvMain.reloadData()
            }
        }
    }
    
    let tvMain: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.tvMain.delegate = self
        self.tvMain.dataSource = self
        setupUI()
        registerCell()
    }
    
    func setupUI() {
        view.addSubview(tvMain)
        
        tvMain.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func registerCell() {
        tvMain.register(RecipeCardSearchCell.self, forCellReuseIdentifier: RecipeCardSearchCell.identifier)
    }
    
    func searchUsers(withKeyword keyword: String) {
        viewModel.searchRecipes(withKeyword: keyword)
    }

}

extension SearchResultVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCardSearchCell.identifier, for: indexPath) as! RecipeCardSearchCell
        let result = searchResults[indexPath.row]
        cell.setData(result)
        cell.category.text = viewModel.searchResults.count.description
        if let imageURL = URL(string: result.photoURL) {
            cell.imageV.kf.setImage(with: imageURL)
        } else {
            cell.imageV.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Check if the indexPath.row is within the bounds of searchResults
        guard indexPath.row < searchResults.count else {
            print("Index out of range")
            return
        }
        
        let selectedRecipe = searchResults[indexPath.row]

        let detailRecipeVC = DetailRecipeVC()
        detailRecipeVC.recipe = selectedRecipe
        detailRecipeVC.detailId = indexPath.row
        let navigationController = UINavigationController(rootViewController: detailRecipeVC)
        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: true, completion: nil)
    }

}

extension SearchResultVC: SearchViewModelDelegate {
    func didFetchRecipes(recipes: [HomeRecipeCardModel], error: Error?) {
        if let error = error {
            print("Error searching recipes: \(error)")
            return
        }
        self.searchResults = recipes 
    }
}
