//
//  JoinRoomViewController.swift
//  MatrixClient
//
//  Created by Avery Pierce on 2/15/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Cocoa

protocol JoinRoomViewControllerDelegate : class {
    func joinRoomViewControllerDidCancel(_ sender: JoinRoomViewController)
    func joinRoomViewControllerDidSubmit(_ sender: JoinRoomViewController)
}


class JoinRoomViewController: NSViewController {
    
    weak var delegate: JoinRoomViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: NSTextField!
    
    var roomIdOrAlias: String { return nameTextField.stringValue }
    
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        delegate?.joinRoomViewControllerDidCancel(self)
    }
    
    @IBAction func createButtonClicked(_ sender: NSButton) {
        delegate?.joinRoomViewControllerDidSubmit(self)
    }
    
}
