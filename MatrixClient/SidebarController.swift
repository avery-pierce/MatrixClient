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

class RoomCellView : NSTableCellView {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var detailTextField: NSTextField!
    @IBOutlet weak var thumbnailImageView: NSImageView?
    
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            switch backgroundStyle {
            case .dark:
                titleTextField.textColor = .white
                detailTextField.textColor = .white
            default:
                titleTextField.textColor = .black
                detailTextField.textColor = .darkGray
            }
        }
    }
}

@objc protocol RoomChangedDelegate : class {
    func roomChanger(_ changer: SidebarController, setRoom room: MXRoom)
}

class SidebarController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, MatrixSessionManagerDelegate, CreateRoomViewControllerDelegate, JoinRoomViewControllerDelegate, NSMenuDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    weak var roomChangedDelegate: RoomChangedDelegate?
    
    enum Section {
        case rooms
    }
    
    var sections: [Section] = [.rooms]
    var rooms: [MXRoom] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.outlineView.expandItem(Section.rooms)
    }
    
    
    func matrixDidStart(_ session: MXSession) {
        self.rooms = session.rooms
        outlineView.reloadData()
    }
    
    func matrixDidLogout() {
        self.rooms = []
        outlineView.reloadData()
    }
    

    
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        print("number of children")
        guard let section = item as? Section else { return sections.count }
     
        switch section {
        case .rooms:
            return rooms.count
        }
    }
    
    
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // Only section items are expandable
        return item is Section
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let section = item as? Section else { return sections[index] }
        
        switch section {
        case .rooms:
            return rooms[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let cellView: NSTableCellView?
        
        switch item {
        case let item as Section:
            cellView = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            switch item {
            case .rooms:
                cellView?.textField?.stringValue = "ROOMS"
            }
        case let item as MXRoom:
            let roomCellView = outlineView.make(withIdentifier: "DataCell", owner: self) as? RoomCellView

            roomCellView?.detailTextField?.stringValue = item.state.canonicalAlias ?? item.state.roomId
            roomCellView?.titleTextField?.stringValue = item.state.name ?? item.state.canonicalAlias ?? "Unnamed Room"
            
            if  let avatarString = item.state.avatar,
                let avatarUrl = URL(string: avatarString)?.resolvingMatrixUrl() {
                
                ImageProvider().image(for: avatarUrl, completion: { (response) in
                    roomCellView?.thumbnailImageView?.image = response.value
                })
            }
            
            cellView = roomCellView
        default:
            cellView = outlineView.make(withIdentifier: "DataCell", owner: item) as? NSTableCellView
        }
        
        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        switch item {
        case _ where item is Section:
            return 17
        case _ where item is MXRoom:
            return 38
        default:
            return 17
        }
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let room = item as? MXRoom else { return false }
        roomChangedDelegate?.roomChanger(self, setRoom: room)
        return true
    }
    
    
    
    
    // MARK: - Create Room Sheet
    
    @IBAction func createRoom(_ sender: NSButton? = nil) {
        
        // Initialize the create room sheet, and become its delegate
        let roomStoryboard = NSStoryboard(name: "RoomManagement", bundle: nil)
        guard
            let parentWindow = self.view.window,
            let roomWindowController = roomStoryboard.instantiateController(withIdentifier: "CreateRoomWindowController") as? NSWindowController,
            let roomWindow = roomWindowController.window,
            let roomViewController = roomWindowController.contentViewController as? CreateRoomViewController
        else { return }
        roomViewController.delegate = self
        
        // Present the create room sheet
        parentWindow.beginSheet(roomWindow, completionHandler: nil)
    }
    
    
    func createRoomViewControllerDidCancel(_ sender: CreateRoomViewController) {
        if let sheetWindow = sender.view.window {
            self.view.window?.endSheet(sheetWindow)
        }
    }
    
    func createRoomViewControllerDidSubmit(_ sender: CreateRoomViewController) {
        MatrixSessionManager.shared.session?.createRoom(name: sender.roomName, visibility: sender.roomVisibility, alias: sender.roomAlias, topic: nil, preset: .publicChat) { response in
            switch response {
            case .success(let room):
                self.rooms.append(room)
                guard let index = self.rooms.index(of: room) else { return }
                self.outlineView.insertItems(at: IndexSet(integer: index), inParent: Section.rooms, withAnimation: NSTableViewAnimationOptions.slideLeft)
            default: break
            }
            
            if let sheetWindow = sender.view.window {
                self.view.window?.endSheet(sheetWindow)
            }
        }
    }
    
    
    
    @IBAction func leaveRoom(_ sender: Any) {
        guard let room = self.outlineView.item(atRow: outlineView.clickedRow) as? MXRoom else { return }
        MatrixSessionManager.shared.session?.leaveRoom(room.roomId) { response in
            guard response.isSuccess else { return }
            
            // Get the index of this room and remove it from the list
            guard let roomIndex = self.rooms.index(of: room) else { return }
            self.rooms.remove(at: roomIndex)
            self.outlineView.removeItems(at: IndexSet(integer: roomIndex), inParent: Section.rooms, withAnimation: .slideLeft)
        }
    }
    
    // MARK: - Join Room Sheet
    
    @IBAction func joinRoom(_ sender: NSButton? = nil) {
        
        // Initialize the join room sheet, and become its delegate
        let roomStoryboard = NSStoryboard(name: "RoomManagement", bundle: nil)
        guard
            let parentWindow = self.view.window,
            let roomWindowController = roomStoryboard.instantiateController(withIdentifier: "JoinRoomWindowController") as? NSWindowController,
            let roomWindow = roomWindowController.window,
            let roomViewController = roomWindowController.contentViewController as? JoinRoomViewController
            else { return }
        roomViewController.delegate = self
        
        // Present the create room sheet
        parentWindow.beginSheet(roomWindow, completionHandler: nil)
        
    }
    
    func joinRoomViewControllerDidCancel(_ sender: JoinRoomViewController) {
        if let sheetWindow = sender.view.window {
            self.view.window?.endSheet(sheetWindow)
        }
    }
    
    
    func joinRoomViewControllerDidSubmit(_ sender: JoinRoomViewController) {
        MatrixSessionManager.shared.session?.joinRoom(sender.roomIdOrAlias)  { response in
            
            switch response {
            case .success(let room):
                self.rooms.append(room)
                guard let index = self.rooms.index(of: room) else { return }
                self.outlineView.insertItems(at: IndexSet(integer: index), inParent: Section.rooms, withAnimation: .slideLeft)
            case .failure: break
            }
            
            if let sheetWindow = sender.view.window {
                self.view.window?.endSheet(sheetWindow)
            }
        }
    }
    
}
