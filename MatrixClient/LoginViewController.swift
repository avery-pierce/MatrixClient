//
//  LoginViewController.swift
//  MatrixClient
//
//  Created by Avery Pierce on 1/23/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Cocoa
import MatrixSDK

protocol LoginViewControllerDelegate {
    func loginViewController(_ sender: LoginViewController, didLoginWith credentials: MXCredentials)
}

class LoginViewController: NSViewController {
    
    @IBOutlet weak var addressTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var loginButton: NSButton!
    
    var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBAction func submitLogin(_ sender: NSButton) {
        let address = addressTextField.stringValue
        let username = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        
        progressIndicator.startAnimation(nil)
        
        let client = MXRestClient(homeServer: URL(string: address)!, unrecognizedCertificateHandler: nil)
        client.login(username: username, password: password) { response in

            // Stop the animation
            self.progressIndicator.stopAnimation(nil)
            
            switch response {
            case .success(let credentials):
                self.delegate?.loginViewController(self, didLoginWith: credentials)
            case .failure:
                self.passwordTextField.stringValue = ""
            }
        }
    }
}
