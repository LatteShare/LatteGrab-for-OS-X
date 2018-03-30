//
//  Utilities.swift
//  LatteGrab
//
//  Created by Eduardo Almeida on 30/03/18.
//  Copyright © 2018 Eduardo Almeida. All rights reserved.
//

import AppKit

func showWarningDialog(question: String, text: String) -> Bool {
    let alert = NSAlert()
    
    alert.messageText = question
    alert.informativeText = text
    
    alert.alertStyle = .warning
    
    alert.addButton(withTitle: "OK")
    
    return alert.runModal() == .alertFirstButtonReturn
}
