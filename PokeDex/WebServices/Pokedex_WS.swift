//
//  Pokedex_WS.swift
//  PokeDex
//
//  Created by Abraham Vazquez on 05/09/20.
//  Copyright © 2020 Abraham Vazquez. All rights reserved.
//

import Foundation

class Pokedex_WS: WebService {
    
    typealias CompletionSearch = ([Pokemon], String) -> ()
    typealias ArrPokemon = [Pokemon]
//    private var arrPokemones: [Pokemon] = [Pokemon]()
    
    override init() {
        super.init()
        strURL = URLService.pokedex.rawValue
    }
    
    func getPokedex(withCompletion handler: @escaping CompletionSearch)  {
        performSearch {[weak self](response) in
            guard let self = self else {
                handler([Pokemon](),NSLocalizedString("Some strange error", comment: "Error"))
                return}
            if let resp = response, let arrPokemon = self.parseData(from: resp){
                DispatchQueue.main.async { handler(arrPokemon, self.strError ?? "")}
            }else{ DispatchQueue.main.async { handler(ArrPokemon(), self.strError ?? "")}}
        }
    }
    
    
    private func parseData(from data : Data) -> ArrPokemon?{
        if let dctResponse = getJSON(fromData: data), let arrDicPokemons = dctResponse["pokemon_entries"] as? [JSONDictionary], arrDicPokemons.count > 0{
            var arrPokemones : ArrPokemon = [Pokemon]()
            for dctPokemons in arrDicPokemons {
                let iEntry : Int = dctPokemons["entry_number"] as? Int ?? 0
                let dctSpecies: JSONDictionary? = dctPokemons["pokemon_species"] as? JSONDictionary
                let strName: String? = dctSpecies?["name"] as? String
                let pokemon = Pokemon(noPokedex: iEntry, strPokeName: strName)
                arrPokemones.append(pokemon)
            }
            return arrPokemones
        }else {
            if let _ = strError{
                let strStatic = NSLocalizedString("Problems with the JSON", comment: "Error")
                self.strError! += "\(strStatic)\n"
            }else{
                strError = ""
                let strStatic = NSLocalizedString("Problems with the JSON", comment: "Error")
                self.strError! += "\(strStatic)\n"
            }
        }
        return nil
    }
}
