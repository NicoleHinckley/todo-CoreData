//
//  AddTodoListItemVC.swift
//  CoreDataToDo
//
//  Created by E Nicole Hinckley on 1/20/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import UIKit
import CoreData

class AddTodoListItemVC: UIViewController {

    // MARK: - Properties
    
    var managedContext : NSManagedObjectContext!
    var todo : Todo?
    
    // MARK: - Outlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segControll: UISegmentedControl!
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!
    // MARK: - Actions
    
 
    @IBAction func donePressed(_ sender: Any) {
        
        guard let title = textView.text, !title.isEmpty else { return }
        
        if let todo = todo {
          
            todo.name = title
            todo.priority = Int16(segControll.selectedSegmentIndex)
        } else {
        
        
        let todo = Todo(context: managedContext)
        todo.name = title
        todo.priority = Int16(segControll.selectedSegmentIndex)
        todo.date = Date()
        }
        do {
            try managedContext.save()
            dismiss(animated: true)
            textView.resignFirstResponder()
        } catch {
            print("Error saving todo", error)
        }
   
        
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("This is being called" )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: .UIKeyboardWillShow,
            object: nil)
    
        textView.becomeFirstResponder()
        
        if let todo = todo {
            textView.text = todo.name
            textView.text = todo.name
            segControll.selectedSegmentIndex = Int(todo.priority)
        }
    }
 
    @objc func keyboardWillShow(sender : Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = sender.userInfo?[key] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        bottomConstraint.constant = keyboardHeight + 16
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension AddTodoListItemVC : UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

