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

    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()
        
        if LatteShare.sharedInstance.getConnection().hasStoredDetails() {
            
        }
        
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        
        if let a = item.attachments {
            attachments = a
        } else {
            attachments = []
        }
        
        updateUI()
        
        for a in attachments {
            if a.hasItemConformingToTypeIdentifier("public.data") {
                a.loadItemForTypeIdentifier("public.data", options: nil, completionHandler: {
                    data, error in
                    
                    if let url = data as? NSURL {
                        var isDir : ObjCBool = false
                        
                        NSFileManager.defaultManager().fileExistsAtPath(url.path!, isDirectory: &isDir)
                        
                        if isDir {
                            return
                        }
                        
                        self.filePaths.append(url.path!)
                        self.fileNames.append(NSString(string: url.path!).lastPathComponent)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateUI()
                        }
                    }
                })
            }
        }
    }
    
    func updateUI() {
        sendButton.enabled = fileNames.count != 0
        
        if fileNames.count > 1 {
            itemCountField.stringValue = "Uploading \(attachments.count) items as a group..."
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
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return NSString(string: fileNames[row])
    }

    @IBAction func send(sender: AnyObject?) {
        sendButton.enabled = false
        
        var ids : [String] = []
        var count = 0
        
        if filePaths.count == 1 {
            let outputItem = NSExtensionItem()
            
            let outputItems = [outputItem]
            
            LatteShare.sharedInstance.getConnection().uploadFile(filePaths[0], success: { url in
                NSPasteboard.generalPasteboard().clearContents()
                NSPasteboard.generalPasteboard().writeObjects([url])
                
                let alert = NSAlert()
                
                alert.messageText = "Upload Successful!"
                alert.informativeText = "The link to your file is now in your clipboard."
                
                alert.runModal()
                
                let ri = RecentItems()
                
                ri.addRecentItem(identifier: url, date: NSDate())
                ri.save()
                
                self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
            }, failure: { error in
                //  Deal with error.
                
                let alert = NSAlert()
                
                alert.messageText = "Upload Error!"
                alert.informativeText = "An error has occurred while uploading the requested file: \(error)"
                
                alert.runModal()
                
                self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
            })
        } else {
            for path in filePaths {
                LatteShare.sharedInstance.getConnection().uploadFile(path, success: { url in
                    print(url)
                    
                    let arr = url.characters.split{ $0 == "/" }.map(String.init)
                    
                    ids.append(arr.last!)
                    
                    count++
                    
                    if count == self.filePaths.count {
                        self.createGroup(ids)
                    }
                }, failure: { error in
                    print(error)
                        
                    count++
                        
                    if count == self.filePaths.count {
                        self.createGroup(ids)
                    }
                })
            }
        }
    }
    
    func createGroup(ids: [String]) {
        let outputItem = NSExtensionItem()
        
        let outputItems = [outputItem]
        
        try! LatteShare.sharedInstance.getConnection().createGroup(ids, success: { url in
            NSPasteboard.generalPasteboard().clearContents()
            NSPasteboard.generalPasteboard().writeObjects([url])
            
            let alert = NSAlert()
            
            alert.messageText = "Upload Successful!"
            alert.informativeText = "The link to your files group is now in your clipboard."
            
            alert.runModal()
            
            let ri = RecentItems()
            
            ri.addRecentItem(identifier: url, date: NSDate())
            ri.save()
            
            self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
        }, failure: { error in
            print(error)
            
            let alert = NSAlert()
            
            alert.messageText = "Upload Error!"
            alert.informativeText = "An error has occurred while uploading the requested files: \(error)"
            
            alert.runModal()
        
            self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
        })
    }

    @IBAction func cancel(sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequestWithError(cancelError)
    }

}
