//
//  SidebarController.swift
//  MatrixClient
//
//  Created by Avery Pierce on 1/19/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

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

class SidebarController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, MatrixSessionManagerDelegate {
    
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

            if let canonicalAlias = item.state.canonicalAlias {
                roomCellView?.detailTextField?.stringValue = canonicalAlias
            } else {
                roomCellView?.detailTextField?.stringValue = item.state.roomId
            }

            if let name = item.state.name {
                roomCellView?.titleTextField?.stringValue = name
            } else {
                if let canonicalAlias = item.state.canonicalAlias {
                    roomCellView?.titleTextField?.stringValue = canonicalAlias
                } else {
                    roomCellView?.titleTextField?.stringValue = "Unnamed Room"
                }
            }
            
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
}
