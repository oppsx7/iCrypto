//
//  AuthVIewController.swift
//  CryptoTracker
//
//  Created by Todor Dimitrov on 15.10.21.
//

import Foundation
import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        presentAuth()
    }
    
    func presentAuth() {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Your crypto is protected by biometrics") { success, error in
            if success {
                DispatchQueue.main.async {
                    let cryptoTableVC = CryptoTableViewController()
                    let navigationController = UINavigationController(rootViewController: cryptoTableVC)
                    self.present(navigationController, animated: true)
                }
            } else {
                self.presentAuth()
            }
        }
    }
}
