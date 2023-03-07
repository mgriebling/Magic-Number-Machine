//
//  ColoredButton.swift
//  TestButton
//
//  Created by Mike Griebling on 2023-03-01.
//

import Cocoa

class ColoredButton: NSButton {
    
    @IBInspectable var bgColor: NSColor = .darkGray { didSet { needsDisplay = true } }
    @IBInspectable var foreColor: NSColor = .labelColor { didSet { needsDisplay = true } }
    
    func configure() {
      //  self.appearance = NSAppearance(named: .vibrantDark)
        let highlightColor: NSColor = bgColor.highlight(withLevel: 0.8)!
        if !isHighlighted  {
            self.layer?.backgroundColor = bgColor.cgColor
        } else {
            self.layer?.backgroundColor = highlightColor.cgColor
//        } else {
//            self.layer?.backgroundColor = bgColor.highlight(withLevel: -0.5)!.cgColor
        }
        self.layer?.borderColor = NSColor.black.cgColor
        self.layer?.borderWidth = 1
        
//        let attributedString = NSAttributedString(string: title,
//                                                  attributes: [NSAttributedString.Key.foregroundColor: foreColor])
//        self.attributedTitle = attributedString
//        let titleParagraphStyle = NSMutableParagraphStyle()
//        titleParagraphStyle.alignment = alignment
//
//        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: foreColor, .paragraphStyle: titleParagraphStyle]
//        if !self.attributedTitle.attributeKeys.isEmpty {
//            var mutableAttributes = self.attributedTitle.mutableArrayValue(forKey: NSAttributedString.Key.foregroundColor.rawValue)
//            // mutableAttributes[NSAttributedString.Key.foregroundColor] = foreColor
//        } else {
//            self.attributedTitle = NSAttributedString(string: self.title, attributes: attributes)
//        }
    }
    
    override func updateLayer() {
        configure()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
//        let highlightColor: NSColor = bgColor.highlight(withLevel: 0.8)!
//        if !isHighlighted  {
//            self.layer?.backgroundColor = bgColor.cgColor
//        } else {
//            self.layer?.backgroundColor = highlightColor.cgColor
////        } else {
////            self.layer?.backgroundColor = bgColor.highlight(withLevel: -0.5)!.cgColor
//        }
    }
    
//    override var allowsVibrancy: Bool { true }
    
    override func awakeFromNib() {
        configure()
    }

}
