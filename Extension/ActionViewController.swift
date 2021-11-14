//
//  ActionViewController.swift
//  Extension
//
//  Created by Keith Crooc on 2021-11-09.
//

// 1. ✅ Add a bar button item that lets users select from a handful of prewritten example scripts, shown using a UIAlertController – at the very least your list should include the example we used in this project.
// 2. You're already receiving the URL of the site the user is on, so use UserDefaults to save the user's JavaScript for each site. You should convert the URL to a URL object in order to use its host property.
// 3. For something bigger, let users name their scripts, then select one to load using a UITableView.

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showPresets))
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    @IBAction func showPresets() {
            let ac = UIAlertController(title: "Choose a Preset", message: "Select a templated javascript action", preferredStyle: .alert)
            
        let alertScript = UIAlertAction(title: "alert()", style: .default) { [weak self, weak ac] action in
            let preset = "alert(document.title)"
            self?.writeScript(preset)
        }
        
        
    
        let messageScript = UIAlertAction(title: "prompt()", style: .default) {
            [weak self, weak ac] action in
            let preset = "prompt()"
            self?.writeScript(preset)
        }
        
        ac.addAction(alertScript)
        ac.addAction(messageScript)
        
        present(ac, animated: true)
            
    }
    
    func writeScript(_ preset: String) {
        script.text = preset
    }
    
    
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
//        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        
        let item = NSExtensionItem()
        let argmument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argmument]
        
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//        we typecast this as an NSValue because Objc doesn't allow for struct such as a CGRect. Apple used NSValue to wrap it so it could be used in objc function. We know in the keyboard Value it's a CGRect but in Swift's eyes it sees it as a cgRectValue property of the CGRect struct
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
//
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
        
    }

}
