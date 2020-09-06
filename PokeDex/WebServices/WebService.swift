//
//  WebService.swift
//  PokeDex
//
//  Created by Abraham Vazquez on 05/09/20.
//  Copyright © 2020 Abraham Vazquez. All rights reserved.
//

import Foundation

class WebService {
    private enum Status : Int {
        case ok = 200
    }
    internal enum URLService:String{
        case pokedex = "https://pokeapi.co/api/v2/pokedex/1"
        case pokemon = "https://pokeapi.co/api/v2/pokemon/"
    }
    internal var strURL : String = ""
    internal var strError : String? = nil
    
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    typealias CompletionRequest = (Data?) -> ()
    typealias JSONDictionary = [String: Any]
    
    internal func performSearch(withCompletion completion : @escaping CompletionRequest){
        guard let url = URL(string: strURL) else { return }
        
        dataTask?.cancel()
        
        dataTask = defaultSession.dataTask(with: url, completionHandler: {[weak self] (datos, response, error) in
            guard let self = self else { return }
            
            defer{ self.dataTask = nil }
            
            if let error = error{
                
                let strStatic = NSLocalizedString("Data task error", comment: "Error")
                if let _ = self.strError{
                    self.strError! += "\(strStatic): \(error.localizedDescription)\n"
                }else{
                    self.strError = ""
                    self.strError! += "\(strStatic): \(error.localizedDescription)\n"
                }
                completion(nil)
            }else if let data = datos, let response = response as? HTTPURLResponse, response.statusCode == Status.ok.rawValue{
                completion(data)
            }
            else{
                let strStatic = NSLocalizedString("Some kind of error", comment: "Error")
                if let _ = self.strError{
                    self.strError! += "\(strStatic)\n"
                }else{
                    self.strError = ""
                    self.strError! += "\(strStatic)\n"
                }
                completion(nil)
            }
        })
        dataTask?.resume()
    }
    
    internal func getJSON(fromData data:Data) -> JSONDictionary? {
        var response : JSONDictionary?
        do{
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        }catch let parseError as NSError{
            let strStatic = NSLocalizedString("JSON Serialization error", comment: "Error")
            
            if let _ = strError{
                strError! += "\(strStatic): \(parseError.localizedDescription)\n"
            }else{
                strError = ""
                strError! += "\(strStatic): \(parseError.localizedDescription)\n"
            }
            return nil
        }
        return response
    }
}
