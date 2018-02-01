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
    
    
    //TODO:
    //https://stackoverflow.com/questions/41947844/adding-paragraph-headings-programatically-to-a-uitextview
    
    struct Formatted {
        var heading: String
        var descriptionText: String
        
        var bodyParagraphStyle: NSMutableParagraphStyle = {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 10
            style.paragraphSpacingBefore = 6
            style.paragraphSpacing = 6
            return style
        }()
        
        var headerParagraphStyle: NSMutableParagraphStyle = {
            let style = NSMutableParagraphStyle()
            style.paragraphSpacingBefore = 24
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
            self.heading = heading
            self.descriptionText = descriptionText
            self.bodyAttributes = [
                NSAttributedStringKey.font: UIFont(name: "Hoefler Text", size: 14)!,
                NSAttributedStringKey.paragraphStyle : bodyParagraphStyle
            ]
            self.headerAttributes = [
                NSAttributedStringKey.font: UIFont(name: "Avenir", size: 22)!,
                NSAttributedStringKey.paragraphStyle: headerParagraphStyle,
                NSAttributedStringKey.foregroundColor: UIColor.red
            ]
        }
    }
 
    var allFormattedDescriptions = [
        Formatted(heading: "Introduction to Bacon Ipsum", descriptionText: "Bacon ipsum dolor amet jerky pig pastrami capicola biltong turkey, ball tip fatback andouille porchetta flank swine brisket bacon pork loin. Tongue shank cupim, pastrami spare ribs meatball drumstick pork pork chop. Sirloin flank tenderloin bresaola doner, cupim ribeye drumstick ham hock t-bone pork short ribs shoulder. Fatback ribeye pastrami pancetta, chuck turkey andouille boudin burgdoggen shoulder tongue kielbasa doner shankle turducken. Rump strip steak drumstick, shankle cupim prosciutto jerky bacon doner. Pork chop jowl burgdoggen, cow turkey ball tip doner. Cow ham meatball chuck flank meatloaf prosciutto.")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
