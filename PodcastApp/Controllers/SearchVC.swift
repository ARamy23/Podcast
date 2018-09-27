//
//  SearchVC.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/22/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD

class PodcastsSearchVC: UITableViewController {

    //MARK:- Datasource
    var podcasts = [Podcast]()
    
    
    //MARK:- Helping Variables
    var timer: Timer?
    
    //MARK:- Helping Constants
    let cellId = "CellID"
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK:- Helping Functions
    
    fileprivate func setupUI()
    {
        setupSearchBar()
        setupTableView()
    }
    
    fileprivate func setupSearchBar()
    {
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func setupTableView()
    {
        tableView.register(nibWithCellClass: PodcastCell.self)
        tableView.separatorStyle = .none
    }
    
    //MARK:- Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: PodcastCell.self)
        let podcast = podcasts[indexPath.row]
        cell.model = podcast
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textColor = UIColor.AppPrimaryColor
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeVC = EpisodesVC()
        let cell = tableView.cellForRow(at: indexPath) as! PodcastCell
        episodeVC.podcast = podcasts[indexPath.row]
        episodeVC.podcastImage = cell.podcastImageView.image
        navigationController?.pushViewController(episodeVC, animated: true)
    }
}

//MARK:- UISearchBarDelegate Methods
extension PodcastsSearchVC: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self ] (_) in
            self?.search(for: searchText)
        })
    }
    
    fileprivate func search(for searchText: String)
    {
        SVProgressHUD.show(withStatus: "Searching...")
        let provider = MoyaProvider<Services>(plugins: [NetworkLoggerPlugin(verbose: true)])
        provider.request(.search(searchText)) { (result) in
            switch result
            {
            case .success(let response):
                do
                {
                    let searchResult = try JSONDecoder().decode(SearchResult.self, from: response.data)
                    if let podcasts = searchResult.results
                    {
                        self.podcasts = podcasts
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
                catch (let err)
                {
                    SVProgressHUD.showError(withStatus: err.localizedDescription)
                    print(err.localizedDescription)
                }
            case .failure(let err):
                SVProgressHUD.showError(withStatus: err.localizedDescription)
            }
        }
    }
}
