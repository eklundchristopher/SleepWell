//
//  MenubarController.swift
//  SleepWell
//
//  Created by Christopher Eklund on 2017-07-02.
//  Copyright © 2017 Christopher Eklund. All rights reserved.
//

import Cocoa
import Foundation

class MenubarController: NSObject {
    @IBOutlet weak var menubar: NSMenu!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var toggleButton: NSMenuItem!
    @IBOutlet weak var intervalLabel: NSTextField!
    @IBOutlet weak var intervalStepper: NSStepper!
    
    var interval = 0
    var enabled = false
    var timeRemaining = 0
    var timer = Timer()
    let menubarIcon = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBAction func toggleTimer(_ sender: NSMenuItem) {
        progressbar.doubleValue = Double(0)
        timeRemaining = interval
        
        if enabled == false {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    @IBAction func setTimeInterval(_ sender: NSStepper) {
        setTime(minutes: sender.integerValue)
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "AppIcon")
        icon?.isTemplate = true
        icon?.size = NSSize.init(width: 18, height: 18)
        
        menubarIcon.image = icon
        menubarIcon.menu = menubar
        
        setTime(minutes: 60)
    }
    
    func getTime() -> Int {
        return interval / 60
    }
    
    
    func setTime(minutes : Int) {
        interval = minutes * 60
        timeRemaining = interval
        
        intervalStepper.stringValue = String(getTime())
        intervalLabel.stringValue = String(getTime()) + " minutes"
    }
    
    func startTimer() {
        enabled = true
        toggleButton.title = "Stop"
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        enabled = false
        toggleButton.title = "Start"
        timerLabel.stringValue = ""
    }
    
    func shutdownComputer() {
        print("Shutting down computer...")
    }
    
    func timerRunning() {
        timeRemaining -= 1
        
        progressbar.doubleValue = Double(1 - (Double(timeRemaining) / Double(interval))) * 100
        
        let hoursLeft = String(format: "%02d", Int(timeRemaining) / 60 / 60 % 60)
        let minutesLeft = String(format: "%02d", Int(timeRemaining) / 60 % 60)
        let secondsLeft = String(format: "%02d", Int(timeRemaining) % 60)
        
        timerLabel.stringValue = "\(hoursLeft) : \(minutesLeft) : \(secondsLeft)"
        
        if (timeRemaining <= 0) {
            stopTimer()
            shutdownComputer()
        }
    }
}
