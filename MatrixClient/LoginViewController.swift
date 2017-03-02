/*
 Copyright 2017 Avery Pierce
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Cocoa
import SwiftMatrixSDK

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
