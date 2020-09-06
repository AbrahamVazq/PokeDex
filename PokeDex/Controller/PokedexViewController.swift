//
//  PokedexViewController.swift
//  PokeDex
//
//  Created by Abraham Vazquez on 05/09/20.
//  Copyright © 2020 Abraham Vazquez. All rights reserved.
//

import UIKit

class PokedexViewController: UIViewController {
    //MARK: - O U T L E T S
    @IBOutlet weak var tblVwPokemon: UITableView!{
        didSet{
            tblVwPokemon.delegate = self
            tblVwPokemon.dataSource = self
        }
    }
    //MARK: - E N U M
    enum WebStates {
        case loading
        case finished
    }
    //MARK: - V A R I A B L E S
    private var arrPokemon: [Pokemon]?
    private var pokedexWS:  Pokedex_WS?
    private var arrPokemonsFiltered : [Pokemon] = [Pokemon]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchEmpty : Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchEmpty
    }
    private var webSatate : WebStates = .loading
    
    //MARK: - O V E R R I D E · P R O P E R T I E S
    override func viewDidLoad() {
        super.viewDidLoad()
        tblVwPokemon.register(UITableViewCell.self,
                              forCellReuseIdentifier: TableViewCellsIdentifiers.simpleCell.rawValue)
        let nib = UINib(nibName: TableViewCellsIdentifiers.loadingCell.rawValue, bundle: nil)
        tblVwPokemon.register(nib, forCellReuseIdentifier: TableViewCellsIdentifiers.loadingCell.rawValue)
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("Pokémon", comment: "Titulo de Vista")
        getPokedexEntries()
    }
    
    //MARK: - F U N C T I O N S
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search a Pokémon", comment: "Search pokemon")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    //MARK: - V A L I D A T I O N S
    
    //MARK: - S E R V I C E S
    private func getPokedexEntries(){
        pokedexWS = Pokedex_WS()
        pokedexWS?.getPokedex(withCompletion: {[weak self] (arrPokemonResponse, strError) in
            guard let self = self else { return }
            
            if strError.count > 0{
                self.present(createSimpleAlertView(messge: strError), animated: true)
            }else{
                self.arrPokemon = arrPokemonResponse
                self.webSatate = .finished
                self.tblVwPokemon.reloadData()
            }
            
        })
    }
    
    
    //MARK: - B U T T O N S · A C T I O N
    
    
    //MARK: - N A V I G A T I O N
    
}

// MARK: - EXT -> T A B L E V I E W · D E L E G A T E
extension PokedexViewController: UITableViewDelegate{
    
}

// MARK: - EXT -> T A B L E V I E W · D A T A S O U R C E
extension PokedexViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch webSatate {
        case .finished:
            if isFiltering{
                return arrPokemonsFiltered.count
            }
            return arrPokemon?.count ?? 0
        case .loading:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch webSatate {
        case .finished:
            if let arrPokemons = arrPokemon, arrPokemons.count > 0{
                let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellsIdentifiers.simpleCell.rawValue, for: indexPath)
                let pokemon = isFiltering ? arrPokemonsFiltered[indexPath.row] : arrPokemons[indexPath.row]
                cell.textLabel?.text = "\(pokemon.noPokedex)- \(pokemon.strPokeName?.capitalized ?? "")"
                return cell
            }
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCellsIdentifiers.loadingCell.rawValue, for: indexPath)
            if let spinner = cell.viewWithTag(100) as? UIActivityIndicatorView{
                spinner.startAnimating()
                return cell
            }
        }
        return UITableViewCell()
    }
}

// MARK: - EXT -> S E A T C H · R E S U L T · U P D A T I N G
extension PokedexViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchPokemon(withText: searchBar.text ?? "")
    }
    
    private func searchPokemon(withText strText : String){
        guard  let arrPokemon = arrPokemon else { return }
        arrPokemonsFiltered = arrPokemon.filter({ (pokemon : Pokemon) -> Bool in
            return (pokemon.strPokeName?.lowercased().contains(strText.lowercased()) ?? false)
        })
        tblVwPokemon.reloadData()
    }
}
