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

class MainSplitViewController: NSSplitViewController, LoginViewControllerDelegate, MatrixSessionManagerDelegate, ConnectionLoadingViewControllerDelegate {

    var loginWindow: NSWindow?
    var loadingWindow: NSWindow?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        presentLoginSheetIfNeeded()
    }
    
    func presentLoginSheetIfNeeded() {
        
        if MatrixSessionManager.shared.state == .notStarted {
            self.showLoadingWindow()
            MatrixSessionManager.shared.start()
        } else if MatrixSessionManager.shared.state == .needsCredentials,
            let loginWindowController = self.storyboard?.instantiateController(withIdentifier: "LoginSheet") as? NSWindowController,
            let loginViewController = loginWindowController.contentViewController as? LoginViewController,
            let loginWindow = loginWindowController.window,
            let mainWindow = self.view.window {
            
            loginViewController.delegate = self
            
            loginWindow.preventsApplicationTerminationWhenModal = false
            
            mainWindow.beginSheet(loginWindow, completionHandler: nil)
            self.loginWindow = loginWindow
        }
    }
    
    
    func loginViewController(_ sender: LoginViewController, didLoginWith credentials: MXCredentials) {
        guard let loginWindow = loginWindow else { return }
        view.window?.endSheet(loginWindow)
        
        MatrixSessionManager.shared.credentials = credentials
        self.showLoadingWindow()
        MatrixSessionManager.shared.start()
    }
    
    func logout(_ sender: Any? = nil) {
        MatrixSessionManager.shared.logout()
    }
    
    func matrixDidStart(_ session: MXSession) {
        self.dismissLoadingWindow()
    }
    func matrixDidLogout() {
        self.presentLoginSheetIfNeeded()
    }
    
    
    
    func showLoadingWindow() {
        guard
            let windowController = self.storyboard?.instantiateController(withIdentifier: "ConnectionLoadingWindowController") as? NSWindowController,
            let connectionLoadingViewController = windowController.contentViewController as? ConnectionLoadingViewController,
            let window = windowController.window
            else { return }
        
        connectionLoadingViewController.urlAddress = MatrixSessionManager.shared.credentials?.homeServer ?? "(unknown)"
        connectionLoadingViewController.delegate = self
        loadingWindow = window
        self.view.window?.beginSheet(window, completionHandler: nil)
    }
    
    func dismissLoadingWindow() {
        guard let loadingWindow = self.loadingWindow else { return }
        self.view.window?.endSheet(loadingWindow)
        self.loadingWindow = nil
    }
    
    func connectionLoadingViewControllerDidClickCancel(_ sender: ConnectionLoadingViewController) {
        MatrixSessionManager.shared.logout()
        dismissLoadingWindow()
        presentLoginSheetIfNeeded()
    }
}


protocol ConnectionLoadingViewControllerDelegate : class {
    func connectionLoadingViewControllerDidClickCancel(_ sender: ConnectionLoadingViewController)
}

class ConnectionLoadingViewController : NSViewController {
    weak var delegate: ConnectionLoadingViewControllerDelegate?
    
    var urlAddress: String = "" {
        didSet { urlAddressLabel?.stringValue = urlAddress }
    }
    @IBOutlet weak var urlAddressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlAddressLabel.stringValue = urlAddress
        progressIndicator.startAnimation(nil)
    }
    
    @IBAction func cancel(_ sender: NSButton! = nil) {
        delegate?.connectionLoadingViewControllerDidClickCancel(self)
    }
}
