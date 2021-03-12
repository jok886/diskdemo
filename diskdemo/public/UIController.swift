//
//  UIController.swift
//  diskdemo
//
//  Created by macliu on 2021/3/11.
//

import Foundation
import UIKit

class UIController {
    class func configureNavBar(navigationController: UINavigationController?){
        //
        navigationController?.navigationBar.barStyle = .black
        //
        navigationController?.navigationBar.barTintColor = UIColor.datalogixxBlue
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //
        navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    class func configureBackground(view: UIView) {
        view.backgroundColor = UIColor.white
    }
    class func showError(vc: UIViewController) {
        let alert = UIAlertController(title: "There Was an Error", message: "Please make sure your device is connected", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    class func showAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
}
