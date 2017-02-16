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
