//
//  MainController.swift
//  TunnelLogger
//
//  Created by Emanuel Mairoll on 21.07.18.
//  Copyright © 2018 Emanuel Mairoll. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import AVFoundation

class MainController : NSObject, CLLocationManagerDelegate{
    let viewController:ViewController
    let remoteControl:RemoteControl
    
    private var loggingValue = false
    private var labelTimer = Timer()
    private var startDate = Date()
    private let locationManager = CLLocationManager()
    private let synth = AVSpeechSynthesizer()
    private var logfile: Logfile?
    
    private var tunnelCount = 0
    private var inTunnel = false
    
    override init() {        
        viewController = ViewController()
        remoteControl = RemoteControl(volumeLockLevel: 0.5)
        
        super.init()
        
        viewController.addButtonPressHandler(target: self, action: #selector(mainButtonPressed))
        
        remoteControl.playPauseHandler = enterOrExitTunnel
        remoteControl.skipHandler = undoLastTunnelEvent
        remoteControl.volumeUpHandler = setQuestionMark
        remoteControl.volumeDownHandler = speakInformation
        
        locationManager.distanceFilter = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func enterOrExitTunnel(){
        if !inTunnel {
            tunnelCount += 1
            inTunnel = true
            viewController.updateCount(newCount: tunnelCount)
            viewController.updateState(inTunnel: inTunnel)

            logfile?.write(event: .EnterTunnel)
            speak(message: "Entering Tunnel \(tunnelCount)")
        } else {
            inTunnel = false
            viewController.updateState(inTunnel: inTunnel)

            logfile?.write(event: .ExitTunnel)
            speak(message: "Exiting Tunnel \(tunnelCount)")
        }
        
    }
    
    func undoLastTunnelEvent(){
        if let undoneEvent = logfile?.undoLastTunnelEvent(){
            switch undoneEvent {
            case .EnterTunnel:
                speak(message: "Undone Entering Tunnel \(tunnelCount)")

                tunnelCount -= 1
                inTunnel = false
                viewController.updateCount(newCount: tunnelCount)
                viewController.updateState(inTunnel: inTunnel)
            case .ExitTunnel:
                speak(message: "Undone Exiting Tunnel \(tunnelCount)")
                
                inTunnel = true
                viewController.updateState(inTunnel: inTunnel)
            case .QuestionMark:
                speak(message: "Undone Setting Question Mark")
            }
        } else {
            speak(message: "No Tunnel Events to undo yet")
        }
    }
    
    func setQuestionMark(){
        logfile?.write(event: .QuestionMark)
        if tunnelCount > 0 {
            speak(message: "Setting Question Mark \(inTunnel ? "in" : "past") Tunnel \(tunnelCount)")
        } else {
            speak(message: "Setting Question Mark prior to logging any tunnels")
        }
    }
    
    func speakInformation(){
        if tunnelCount > 0 {
            speak(message: "Currently \(inTunnel ? "in" : "past") Tunnel \(tunnelCount)")
        } else {
            speak(message: "No Tunnels logged yet")
        }
    }
    
    var logging: Bool {
        set {
            if (newValue && !loggingValue) {
                loggingValue = enableLogging()
            } else if (!newValue && loggingValue){
                loggingValue = !disableLogging()
            }
        }
        get {
            return loggingValue
        }
    }

    private func enableLogging() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            labelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateLabelTimer)), userInfo: nil, repeats: true)
            startDate = Date();
            
            
            logfile = Logfile(filename: "test", startDate: startDate)
            logfile?.write(message: "START LOGGING")

            locationManager.startUpdatingLocation()
            remoteControl.active = true
            return true
        } else {
            return false
        }
    }
    
    private func disableLogging() -> Bool {
        labelTimer.invalidate()
        viewController.updateTimer(newSeconds: 0)
        
        tunnelCount = 0
        inTunnel = false
        viewController.updateCount(newCount: tunnelCount)
        viewController.updateState(inTunnel: inTunnel)
        
        locationManager.stopUpdatingLocation()
        remoteControl.active = false
        logfile?.write(message: "STOP LOGGING")
        return true
    }
    
    @objc func mainButtonPressed(sender:UIButton){
        if logging{
            let alert = UIAlertController(title: "Stop Tunnel Logging?", message: "Are you sure you want to stop logging now? Your Log will be saved in the Documents Folder", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.logging = false
                self.viewController.updateButtonTitle(isLogging: false)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            viewController.present(alert, animated: true)
        } else {
            logging = true
            viewController.updateButtonTitle(isLogging: true)
        }
    }
    
    @objc private func updateLabelTimer(){
        viewController.updateTimer(newSeconds: Int(Date().timeIntervalSince(startDate)))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            logfile?.write(location: location)
        }
    }
    
    func speak(message: String){
        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = 0.5
        if synth.isSpeaking {
           synth.stopSpeaking(at: .immediate)
        }
        synth.speak(utterance)
    }
}
