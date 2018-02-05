//
//  EAAboutAppViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 31/01/2018.
//  Copyright © 2018 KC. All rights reserved.
//

import UIKit

class EAAboutAppViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    struct Formatted {
        var heading: String
        var descriptionText: String
        
        var bodyParagraphStyle: NSMutableParagraphStyle = {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 0
            style.paragraphSpacingBefore = 0
            style.paragraphSpacing = 2
            return style
        }()
        
        var headerParagraphStyle: NSMutableParagraphStyle = {
            let style = NSMutableParagraphStyle()
            style.paragraphSpacingBefore = 20
            style.paragraphSpacing = 5
            return style
        }()
        
        var bodyAttributes: [NSAttributedStringKey: Any]
        var headerAttributes: [NSAttributedStringKey: Any]
        
        func attributeString(includeLineBreak: Bool = true) -> NSAttributedString {
            let result = NSMutableAttributedString()
            result.append(NSAttributedString(string: self.heading + "\n", attributes: self.headerAttributes))
            result.append(NSAttributedString(string: self.descriptionText, attributes: self.bodyAttributes))
            if includeLineBreak {
                result.append(NSAttributedString(string: "\n", attributes: self.bodyAttributes))
            }
            
            return result as NSAttributedString
        }
        
        init(heading: String, descriptionText: String) {
            UIFont.systemFont(ofSize: 34)
            self.heading = heading
            self.descriptionText = descriptionText
            self.bodyAttributes = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.paragraphStyle : bodyParagraphStyle,
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
            self.headerAttributes = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold),
                NSAttributedStringKey.paragraphStyle: headerParagraphStyle,
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        }
    }
 
    var allFormattedDescriptions = [
        Formatted(heading: EAUIText.ABOUT_APP_MAIN_HEADING, descriptionText: EAUIText.ABOUT_APP_MAIN_BODY),
        Formatted(heading: EAUIText.ABOUT_APP_DEVELOPED_BY_HEADING, descriptionText: EAUIText.ABOUT_APP_DEVELOPED_BY_BODY),
        Formatted(heading: EAUIText.ABOUT_APP_ICONS_HEADING, descriptionText: EAUIText.ABOUT_APP_ICONS_BODY)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
    }
    
    private func setupTextView() {
        textView.dataDetectorTypes = .all
        textView.isEditable = false
        textView.linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
            NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleSingle.rawValue,
            NSAttributedStringKey.underlineColor.rawValue : UIColor.white
        ]
        let textContent = NSMutableAttributedString()
        for (index, desc) in allFormattedDescriptions.enumerated() {
            let includeLinebreak = index < allFormattedDescriptions.count - 1
            textContent.append(desc.attributeString(includeLineBreak: includeLinebreak))
        }
        textView.attributedText = textContent
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
