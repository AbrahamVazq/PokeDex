//
//  Pokemon_WS.swift
//  PokeDex
//
//  Created by Abraham Vazquez on 05/09/20.
//  Copyright © 2020 Abraham Vazquez. All rights reserved.
//

import Foundation

class Pokemon_WS: WebService {
    typealias CompletionPokemon = (Sprite, String) -> Void
    
    init(iIndex : Int) {
        super.init()
        strURL = "\(URLService.pokemon.rawValue)\(iIndex)"
    }
    
    func getSprites(WithCompletionHandler handler : @escaping CompletionPokemon){
        performSearch {[weak self] (response) in
            guard let self = self else {
                handler(Sprite(), NSLocalizedString("Some strange error", comment: "Error"))
                return
            }
            
            if let resp = response, let sprite = self.searchSprite(fromResponse: resp){
                DispatchQueue.main.async{
                    handler(sprite, self.strError ?? "")
                }
            }else{
                DispatchQueue.main.async{
                    handler(Sprite(), self.strError ?? "")
                }
            }
            
        }
    }
    
    private func searchSprite(fromResponse response : Data) -> Sprite?{
        if let dctResponse = getJSON(fromData: response), let dctSprites = dctResponse["sprites"] as? [String : Any], let strURLFront = dctSprites["front_default"] as? String{
            return Sprite(strUrlDefaultFront: strURLFront)
        }else{
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
