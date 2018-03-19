//
//  ShareViewController.swift
//  FinderShareExtension
//
//  Created by Eduardo Almeida on 10/02/16.
//  Copyright © 2016 Eduardo Almeida. All rights reserved.
//

import Cocoa

import LatteShare

class ShareViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet weak var itemCountField: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    var attachments : [AnyObject] = []
    
    var filePaths : [String] = []
    var fileNames : [String] = []

    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }

    override func loadView() {
        super.loadView()
        
        if LatteShare.sharedInstance.getConnection().hasStoredDetails() {
            
        }
        
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        
        if let a = item.attachments {
            attachments = a as [AnyObject]
        } else {
            attachments = []
        }
        
        updateUI()
        
        for a in attachments {
            if a.hasItemConformingToTypeIdentifier("public.data") {
                a.loadItem(forTypeIdentifier: "public.data", options: nil, completionHandler: {
                    data, error in
                    
                    if let url = data as? NSURL {
                        var isDir : ObjCBool = false
                        
                        FileManager.default.fileExists(atPath: url.path!, isDirectory: &isDir)
                        
                        if isDir.boolValue {
                            return
                        }
                        
                        self.filePaths.append(url.path!)
                        self.fileNames.append(NSString(string: url.path!).lastPathComponent)
                        
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                    }
                })
            }
        }
    }
    
    func updateUI() {
        sendButton.isEnabled = fileNames.count != 0
        
        if fileNames.count > 1 {
            itemCountField.stringValue = "Uploading \(fileNames.count) items as a group..."
        } else if fileNames.count == 1 {
            itemCountField.stringValue = "Uploading a single file..."
        } else {
            itemCountField.stringValue = "No files selected."
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return fileNames.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return NSString(string: fileNames[row])
    }

    @IBAction func send(sender: AnyObject?) {
        sendButton.isEnabled = false
        
        var ids : [String] = []
        var count = 0
        
        if filePaths.count == 1 {
            let outputItem = NSExtensionItem()
            
            let outputItems = [outputItem]
            
            LatteShare.sharedInstance.getConnection().uploadFile(filePath: filePaths[0], success: { url in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([url as NSPasteboardWriting])
                
                let alert = NSAlert()
                
                alert.messageText = "Upload Successful!"
                alert.informativeText = "The link to your file is now in your clipboard."
                
                alert.runModal()
                
                let ri = RecentItems()
                
                ri.addRecentItem(identifier: url, date: NSDate())
                ri.save()
                
                self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
            }, failure: { error in
                //  Deal with error.
                
                let alert = NSAlert()
                
                alert.messageText = "Upload Error!"
                alert.informativeText = "An error has occurred while uploading the requested file: \(error)"
                
                alert.runModal()
                
                self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
            })
        } else {
            for path in filePaths {
                LatteShare.sharedInstance.getConnection().uploadFile(filePath: path, success: { url in
                    print(url)
                    
                    let arr = url.split{ $0 == "/" }.map(String.init)
                    
                    ids.append(arr.last!)
                    
                    count += 1
                    
                    if count == self.filePaths.count {
                        self.createGroup(ids: ids)
                    }
                }, failure: { error in
                    print(error)
                        
                    count += 1
                        
                    if count == self.filePaths.count {
                        self.createGroup(ids: ids)
                    }
                })
            }
        }
    }
    
    func createGroup(ids: [String]) {
        let outputItem = NSExtensionItem()
        
        let outputItems = [outputItem]
        
        do {
            try LatteShare.sharedInstance.getConnection().createGroup(fileIdentifiers: ids, success: { url in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([url as NSPasteboardWriting])
                
                let alert = NSAlert()
                
                alert.messageText = "Upload Successful!"
                alert.informativeText = "The link to your files group is now in your clipboard."
                
                alert.runModal()
                
                let ri = RecentItems()
                
                ri.addRecentItem(identifier: url, date: NSDate())
                ri.save()
                
                self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
                }, failure: { error in
                    print(error)
                    
                    let alert = NSAlert()
                    
                    alert.messageText = "Upload Error!"
                    alert.informativeText = "An error has occurred while uploading the requested files: \(error)"
                    
                    alert.runModal()
                    
                    self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
            })
        } catch let e {
            print("Exception at createGroup! \(e)")
        }
    }

    @IBAction func cancel(sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}
