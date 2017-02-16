//
//  CreateRoomViewController.swift
//  MatrixClient
//
//  Created by Avery Pierce on 2/15/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Cocoa
import MatrixSDK

protocol CreateRoomViewControllerDelegate : class {
    func createRoomViewControllerDidCancel(_ sender: CreateRoomViewController)
    func createRoomViewControllerDidSubmit(_ sender: CreateRoomViewController)
}

class CreateRoomViewController: NSViewController {
    
    weak var delegate: CreateRoomViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var aliasTextField: NSTextField!
    @IBOutlet weak var visibilityPopUpButton: NSPopUpButton!
    
    var roomName: String { return nameTextField.stringValue }
    var roomAlias: String { return aliasTextField.stringValue }
    var roomVisibility: MXRoomDirectoryVisibility {
        switch visibilityPopUpButton.titleOfSelectedItem ?? "" {
        case "Public": return .public
        case "Private": return .private
        default: return .private // This should never run...
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        delegate?.createRoomViewControllerDidCancel(self)
    }
    
    @IBAction func createButtonClicked(_ sender: NSButton) {
        delegate?.createRoomViewControllerDidSubmit(self)
    }
    
}
