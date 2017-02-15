//
//  AppDelegate.swift
//  MatrixClient
//
//  Created by Avery Pierce on 1/14/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Cocoa
import MatrixSDK

protocol MatrixSessionManagerDelegate {
    func matrixDidStart(_ session: MXSession)
    func matrixDidLogout()
}

class MatrixSessionManager {
    static let shared = MatrixSessionManager()
    
    static let credentialsDictionaryKey = "MatrixCredentials"
    
    enum State {
        case needsCredentials, notStarted, starting, started
    }
    
    private(set) var state: State
    
    var credentials: MXCredentials? {
        didSet {
            
            // Make sure to synchronize the user defaults after we're done here
            defer { UserDefaults.standard.synchronize() }
            
            guard
                let homeServer = credentials?.homeServer,
                let userId = credentials?.userId,
                let token = credentials?.accessToken
                else { UserDefaults.standard.removeObject(forKey: "MatrixCredentials"); return }
            
            let storedCredentials: [String: String] = [
                "homeServer": homeServer,
                "userId": userId,
                "token": token
            ]
            
            UserDefaults.standard.set(storedCredentials, forKey: "MatrixCredentials")
        }
    }
    var session: MXSession?
    var delegate: MatrixSessionManagerDelegate?
    
    init() {
        
        // Make sure that someone is logged in.
        if  let savedCredentials = UserDefaults.standard.dictionary(forKey: MatrixSessionManager.credentialsDictionaryKey),
            let homeServer = savedCredentials["homeServer"] as? String,
            let userId = savedCredentials["userId"] as? String,
            let token = savedCredentials["token"] as? String {

            credentials = MXCredentials(homeServer: homeServer, userId: userId, accessToken: token)
            state = .notStarted
        } else {
            state = .needsCredentials
            credentials = nil
        }
    }
    
    func start() {
        guard let credentials = credentials else { return }
        
        let restClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        session = MXSession(matrixRestClient: restClient)
        
        state = .starting
        
        let fileStore = MXFileStore()
        session?.setStore(fileStore) { response in
            if case .failure(let error) = response {
                print("An error occurred setting the store: \(error)")
                return
            }
            
            self.state = .starting
            self.session?.start { response in
                guard response.isSuccess else { return }
                
                DispatchQueue.main.async {
                    self.delegate?.matrixDidStart(self.session!);
                    self.state = .started
                }
            }
        }
    }
    
    func logout() {
        
        print("Logging out!")
        
        session?.logout { _ in
            UserDefaults.standard.removeObject(forKey: MatrixSessionManager.credentialsDictionaryKey)
            UserDefaults.standard.synchronize()
            
            self.credentials = nil
            self.state = .needsCredentials
            
            self.delegate?.matrixDidLogout()
        }
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MatrixSessionManagerDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        MatrixSessionManager.shared.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    
    func matrixDidStart(_ session: MXSession) {
        let allViewControllers = NSApplication.shared().windows.flatMap({ return $0.descendentViewControllers })
        
        allViewControllers.flatMap({ return $0 as? MatrixSessionManagerDelegate }).forEach { (delegate) in
            delegate.matrixDidStart(session)
        }
    }
    
    func matrixDidLogout() {
        let allViewControllers = NSApplication.shared().windows.flatMap({ return $0.descendentViewControllers })
        
        allViewControllers.flatMap({ return $0 as? MatrixSessionManagerDelegate }).forEach { (delegate) in
            delegate.matrixDidLogout()
        }
    }
}

fileprivate extension NSWindow {
    var descendentViewControllers: [NSViewController] {
        var descendents = [NSViewController]()
        if let rootViewController = windowController?.contentViewController {
            descendents.append(rootViewController)
            descendents.append(contentsOf: rootViewController.descendentViewControllers)
        }
        return descendents
    }
}

fileprivate extension NSViewController {
    var descendentViewControllers: [NSViewController] {
        // Capture this view controller's children, and add their descendents
        var descendents = childViewControllers
        descendents.append(contentsOf: childViewControllers.flatMap({ return $0.descendentViewControllers }))
        return descendents
    }
}
