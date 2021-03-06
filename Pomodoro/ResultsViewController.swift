//
//  ResultsViewController.swift
//  Pomodoro
//
//  Created by Chelsea Valentine on 9/1/16.
//  Copyright © 2016 Chelsea Valentine. All rights reserved.
//

import Foundation
import Cocoa

class ResultsViewController: NSViewController {
    
    @IBOutlet weak var sessionTitle: NSTextField!
    @IBOutlet weak var workDuration: NSTextField!
    @IBOutlet weak var focusText: NSTextField!
    @IBOutlet weak var breakText: NSTextField!
    @IBOutlet weak var breakIcon: NSImageView!
    @IBOutlet weak var workProgressBar: NSBox!
    @IBOutlet weak var resultTextField: NSTextField!
    
    var breakCount: Int?
    var workCount: Int?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Initialize style
        StyleHelper.setGeneralStyles(self)
        StyleHelper.setPlaceholder(resultTextField, string: Strings.EnterResultPrompt.rawValue, bold: false)
        
        // Load data
        let context = DataManager.getContext()!
        let mode = context.modeRelationship
        let session = context.sessionRelationship
        
        focusText.stringValue = session.goal!
        workDuration.stringValue = TimeHelper.toTimeString(mode.workCount as Int)
        
        sessionTitle.stringValue = Strings.WorkSessionTitle.rawValue + " " + String(session.num)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        initProgressBar()
    }
    
    override func viewDidAppear() {
        super.viewDidLoad()
        
        // Listen for the keyup event
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyUpMask) { (aEvent) -> NSEvent! in
            self.keyUp(aEvent)
            return aEvent
        }
        
        // Initialize start break button
        let gesture = NSClickGestureRecognizer()
        gesture.buttonMask = 0x1 // left mouse
        gesture.target = self
        gesture.action = #selector(ResultsViewController.validateResultField)
        breakIcon.addGestureRecognizer(gesture)
        breakText.addGestureRecognizer(gesture)
        
        // Focus on result field
        resultTextField.lockFocus()
    }

    private func initProgressBar() {
        let mode = DataManager.getContext()!.modeRelationship
        
        workCount = mode.workCount as Int
        breakCount = mode.breakCount as Int
        
        let totalCycleCount = Double(breakCount! + workCount!)
        let workPercentage: Double = (Double(workCount!) / totalCycleCount)
        
        ViewHelper.updateProgressBar(self, bar: workProgressBar, percentage: workPercentage, startX: 0)
    }
    
    override func keyUp(theEvent: NSEvent) {
        if (resultTextField.stringValue != "") {
            // User has inputted a valid value
            breakIcon.image = NSImage(named: "yellowResumeIcon")
            breakText.textColor = NSColor(red: 255, green: 234, blue: 64, alpha: 1.0)
        } else {
            // Emphasize need to enter result
            breakIcon.image = NSImage(named: "whiteResumeIcon")
            breakText.textColor = NSColor(white: 1.0, alpha: 0.65)
        }
        
        if (theEvent.keyCode == Keys.ReturnKey.rawValue) {
            validateResultField()
        } else {
            // Emphasize need to enter result
            StyleHelper.setPlaceholder(resultTextField, string: Strings.EnterResultPrompt.rawValue, bold: false)
        }
    }
    
    func validateResultField() {
        if (resultTextField.stringValue == "") {
            StyleHelper.setPlaceholder(resultTextField, string: Strings.EnterResultPrompt.rawValue, bold: true)
        } else {
            resultTextField.enabled = false
            
            // Save results
            let context = DataManager.getContext()!
            let mode = context.modeRelationship
            let session = context.sessionRelationship
            session.result = resultTextField.stringValue
            
            // Prepare for break part of session
            context.count = mode.breakCount
            context.isBreak = true
            
            DataManager.saveManagedContext()
            
            goToBreakViewController()
        }
    }
    
    private func goToBreakViewController() {
        let nextViewController = self.storyboard?.instantiateControllerWithIdentifier(ViewControllerName.Break.rawValue) as? BreakViewController
        self.view.window?.contentViewController = nextViewController
    }
}