//
//  Functions.swift
//  PokeDex
//
//  Created by Abraham Vazquez on 05/09/20.
//  Copyright © 2020 Abraham Vazquez. All rights reserved.
//

import UIKit

enum TableViewCellsIdentifiers: String{
    case simpleCell = "SimpleCell"
    case loadingCell = "LoadingCell"
}

func createSimpleAlertView(withTitle strTitle : String = NSLocalizedString("Pokemon", comment: "App title"), messge strMessage : String, actionTitle strActionTitle : String = NSLocalizedString("Accept", comment: "Aceptar"), andHandler handler : ((UIAlertAction) -> ())? = nil) -> UIAlertController{
    let alert = UIAlertController(title: strTitle, message: strMessage, preferredStyle: .alert)
    
    let action = UIAlertAction(title: strActionTitle, style: .default, handler: handler)
    alert.addAction(action)
    
    return alert
    
}
