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
    @IBOutlet weak var intervalLabel: NSTextField!
    @IBOutlet weak var intervalStepper: NSStepper!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var restartButton: NSButton!
    
    var interval = 0
    dynamic var enabled: NSNumber? = false
    dynamic var disabled: NSNumber? = true
    dynamic var isSavingInterval: NSNumber? = false
    dynamic var prefersSleeping: NSNumber? = false
    var timeRemaining = 0
    var timer = Timer()
    let menubarIcon = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBAction func toggleTimer(_ sender: NSButton) {
        progressbar.doubleValue = Double(0)
        timeRemaining = interval
        
        if isEnabled() == false {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    @IBAction func resetTimer(_ sender: NSButton) {
        progressbar.doubleValue = Double(0)
        timeRemaining = interval
    }
    
    @IBAction func setTimeInterval(_ sender: NSStepper) {
        setTime(minutes: sender.integerValue)
    }
    
    @IBAction func toggleSaveInterval(_ sender: NSButton) {
        isSavingInterval = sender.state as NSNumber
        writePlist(namePlist: "Preferences", key: "Save Interval", data: isSavingInterval!)
    }
    
    @IBAction func togglePrefersSleeping(_ sender: NSButton) {
        prefersSleeping = sender.state as NSNumber
        writePlist(namePlist: "Preferences", key: "Sleep", data: prefersSleeping!)
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "AppIcon")
        icon?.isTemplate = true
        icon?.size = NSSize.init(width: 18, height: 18)
        
        menubarIcon.image = icon
        menubarIcon.menu = menubar
        
        isSavingInterval = readPlist(namePlist: "Preferences", key: "Save Interval") as? NSNumber
        prefersSleeping = readPlist(namePlist: "Preferences", key: "Sleep") as? NSNumber
        
        var minutes = 60
        let savedMinutes = readPlist(namePlist: "Preferences", key: "Interval") as! Int
        if savedMinutes > 0 {
            minutes = savedMinutes
        }
        
        setTime(minutes: minutes)
        setControlButtonStates()
    }
    
    func isEnabled() -> Bool {
        return (enabled?.boolValue)!
    }
    
    func enable() {
        enabled = NSNumber?.init(true)
        disabled = NSNumber?.init(false)
    }
    
    func disable() {
        enabled = NSNumber?.init(false)
        disabled = NSNumber?.init(true)
    }
    
    func getTime() -> Int {
        return interval / 60
    }
    
    func setControlButtonStates() {
        startButton.image?.isTemplate = true
        stopButton.image?.isTemplate = true
        restartButton.image?.isTemplate = true
    }
    
    func setTime(minutes : Int) {
        interval = minutes * 60
        timeRemaining = interval
        
        intervalStepper.stringValue = String(getTime())
        intervalLabel.stringValue = String(getTime()) + " minutes"
        
        if isSavingInterval?.boolValue == true {
            writePlist(namePlist: "Preferences", key: "Interval", data: (interval / 60) as NSNumber)
        }
    }
    
    func startTimer() {
        enable()
        
        DispatchQueue.main.async {
            self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    func stopTimer() {
        disable()
        
        timer.invalidate()
        timerLabel.stringValue = ""
        progressbar.doubleValue = Double(0)
    }
    
    func shutdownComputer() {
        if prefersSleeping == true {
            NSAppleScript(source: "tell application \"Finder\"\nsleep\nend tell")!.executeAndReturnError(nil)
        } else {
            NSAppleScript(source: "tell application \"Finder\"\nshut down\nend tell")!.executeAndReturnError(nil)
        }
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
    
    func readPlist(namePlist: String, key: String) -> AnyObject{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent(namePlist+".plist")
        
        var output:Any = false
        
        if let dict = NSMutableDictionary(contentsOfFile: path){
            output = dict.object(forKey: key)!
        }else{
            if let privPath = Bundle.main.path(forResource: namePlist, ofType: "plist"){
                if let dict = NSMutableDictionary(contentsOfFile: privPath){
                    output = dict.object(forKey: key)!
                }else{
                    output = false
                    print("error_read")
                }
            }else{
                output = false
                print("error_read")
            }
        }
        return output as AnyObject
    }
    
    func writePlist(namePlist: String, key: String, data: AnyObject){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent(namePlist+".plist")
        
        if let dict = NSMutableDictionary(contentsOfFile: path){
            dict.setObject(data, forKey: key as NSCopying)
            if dict.write(toFile: path, atomically: true){
                print("plist_write")
            }else{
                print("plist_write_error")
            }
        }else{
            if let privPath = Bundle.main.path(forResource: namePlist, ofType: "plist"){
                if let dict = NSMutableDictionary(contentsOfFile: privPath){
                    dict.setObject(data, forKey: key as NSCopying)
                    if dict.write(toFile: path, atomically: true){
                        print("plist_write")
                    }else{
                        print("plist_write_error")
                    }
                }else{
                    print("plist_write")
                }
            }else{
                print("error_find_plist")
            }
        }
    }
}
