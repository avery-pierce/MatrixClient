//
//  RoundedColorView.swift
//  MatrixClient
//
//  Created by Avery Pierce on 2/4/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Cocoa

class RoundedColorView: RoundedCornerView {
    
    @IBInspectable public var backgroundColor: NSColor = .white
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Fill the background
        backgroundColor.setFill()
        NSRectFill(dirtyRect)
    }
}

class RoundedCornerView : NSView {
    @IBInspectable public var borderWidth: CGFloat = 0.0
    @IBInspectable public var borderColor: NSColor = .black
    @IBInspectable public var cornerRadius: CGFloat = 0.0
    
    override func awakeFromNib() {
        self.wantsLayer = true
        self.layer?.cornerRadius = cornerRadius
        self.layer?.borderWidth = borderWidth
        self.layer?.borderColor = borderColor.cgColor
    }
}

class DropShadowView : RoundedCornerView {
    @IBInspectable public var shadowOffsetX: CGFloat = 0.0
    @IBInspectable public var shadowOffsetY: CGFloat = 0.0
    @IBInspectable public var shadowRadius: CGFloat = 0.0
    @IBInspectable public var shadowColor: NSColor = .black
    @IBInspectable public var shadowOpacity: Float = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer?.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY * -1)
        self.layer?.shadowRadius = shadowRadius
        self.layer?.shadowColor = shadowColor.cgColor
        self.layer?.shadowOpacity = shadowOpacity
        self.layer?.masksToBounds = false
    }
}
