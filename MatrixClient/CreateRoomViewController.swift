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
