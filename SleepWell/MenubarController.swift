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
    @IBOutlet weak var intervalMenu: NSMenu!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var toggleButton: NSMenuItem!
    
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
    
    @IBAction func setTimerTo15Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 15, current: sender)
    }
    
    @IBAction func setTimerTo30Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 30, current: sender)
    }
    
    @IBAction func setTimerTo45Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 45, current: sender)
    }
    
    @IBAction func setTimerTo60Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 60, current: sender)
    }
    
    @IBAction func setTimerTo90Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 90, current: sender)
    }
    
    @IBAction func setTimerTo120Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 120, current: sender)
    }
    
    @IBAction func setTimerTo180Minutes(_ sender: NSMenuItem) {
        setTimerTo(minutes: 180, current: sender)
    }
    
    @IBAction func updateCustomTimerMinutes(_ sender: NSTextFieldCell) {
        setTimerTo(minutes: sender.integerValue)
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "AppIcon")
        icon?.isTemplate = true
        icon?.size = NSSize.init(width: 18, height: 18)
        menubarIcon.image = icon
        menubarIcon.menu = menubar
        
        if let screen = NSScreen.main() {
            print(screen.backingScaleFactor)
        }
        
        setTime(minutes: 60)
    }
    
    func setTimerTo(minutes : Int, current : NSMenuItem! = nil) {
        for menuItem in intervalMenu.items {
            if menuItem.state == NSOnState {
                menuItem.state = NSOffState
                break
            }
        }
        
        if (current != nil) {
            current.state = NSOnState
        }
        
        setTime(minutes: minutes)
        print("Setting timer to " + String(minutes))
    }
    
    func getTime() -> Int {
        return interval
    }
    
    
    func setTime(minutes : Int) {
        interval = minutes * 60
        timeRemaining = interval
    }
    
    func startTimer() {
        enabled = true
        toggleButton.title = "Stop Countdown"
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        enabled = false
        toggleButton.title = "Start Countdown"
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
        
        timerLabel.stringValue = "\(hoursLeft):\(minutesLeft):\(secondsLeft)"
        
        if (timeRemaining <= 0) {
            stopTimer()
            shutdownComputer()
        }
    }
}
