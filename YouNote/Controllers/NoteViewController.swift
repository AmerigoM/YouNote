//
//  NoteViewController.swift
//  YouNote
//
//  Created by Amerigo Mancino on 18/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit

protocol CanReceive {
    func dataReceived(data: String)
}

class NoteViewController: UIViewController, UITextViewDelegate {

    // the text view
    @IBOutlet weak var noteTextView: UITextView!
    
    // the note text
    var noteText : String?
    
    var delegate: CanReceive?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if noteText != nil {
            noteTextView.text = self.noteText
        } else {
            noteTextView.text = ""
        }
        
        // list of delegates
        noteTextView.delegate = self
    }
    
    // MARK: - Text View delegate methods
    
    // triggers when the user press done on keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            view.endEditing(true)
            delegate?.dataReceived(data: noteTextView.text!)
            return false
        }
        
        return true
        
    }

}
