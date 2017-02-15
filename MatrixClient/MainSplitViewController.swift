//
//  MainSplitViewController.swift
//  MatrixClient
//
//  Created by Avery Pierce on 1/22/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Cocoa
import MatrixSDK

class MainSplitViewController: NSSplitViewController, LoginViewControllerDelegate, MatrixSessionManagerDelegate {

    var loginWindow: NSWindow?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        presentLoginSheetIfNeeded()
    }
    
    func presentLoginSheetIfNeeded() {
        
        if MatrixSessionManager.shared.state == .notStarted {
            MatrixSessionManager.shared.start()
        } else if MatrixSessionManager.shared.state == .needsCredentials,
            let loginWindowController = self.storyboard?.instantiateController(withIdentifier: "LoginSheet") as? NSWindowController,
            let loginViewController = loginWindowController.contentViewController as? LoginViewController,
            let loginWindow = loginWindowController.window,
            let mainWindow = self.view.window {
            
            loginViewController.delegate = self
            
            mainWindow.beginSheet(loginWindow, completionHandler: nil)
            self.loginWindow = loginWindow
        }
    }
    
    
    func loginViewController(_ sender: LoginViewController, didLoginWith credentials: MXCredentials) {
        guard let loginWindow = loginWindow else { return }
        view.window?.endSheet(loginWindow)
        
        MatrixSessionManager.shared.credentials = credentials
        MatrixSessionManager.shared.start()
    }
    
    func logout(_ sender: Any? = nil) {
        MatrixSessionManager.shared.logout()
    }
    
    func matrixDidStart(_ session: MXSession) {}
    func matrixDidLogout() {
        self.presentLoginSheetIfNeeded()
    }
}
