//
//  HeadphoneEventManager.swift
//  TunnelLogger
//
//  Created by Emanuel Mairoll on 23.07.18.
//  Copyright © 2018 Emanuel Mairoll. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer


class RemoteControl : NSObject, AVAudioPlayerDelegate{
    public typealias Handler = () -> Void

    private let avAudioSession = AVAudioSession.sharedInstance()
    private let volumeLockLevel: Float
    private var player:AVAudioPlayer
    private var observer:NSKeyValueObservation?
    private var isActive = false
    
    var playPauseHandler:Handler?
    var skipHandler:Handler?
    var backHandler:Handler?
    var volumeUpHandler:Handler?
    var volumeDownHandler:Handler?

    var active:Bool {
        get {
            return isActive
        }
        set {
            if newValue{
                UIApplication.shared.beginReceivingRemoteControlEvents()
                try? avAudioSession.setCategory(.playback, mode: .default, options: [])
                resumeAudio()
            } else {
                UIApplication.shared.endReceivingRemoteControlEvents()
                suspendAudio()
            }
            isActive = newValue
        }
    }
    
    init(volumeLockLevel: Float) {
        if UserDefaults.standard.bool(forKey: "play_noise"){
            player = try! AVAudioPlayer(contentsOf:  URL.init(fileURLWithPath: Bundle.main.path(forResource: "Noise", ofType: "mp3")!))
        } else {
            player = try! AVAudioPlayer(contentsOf:  URL.init(fileURLWithPath: Bundle.main.path(forResource: "Silence", ofType: "mp3")!))
        }
        
        player.volume = 1
        player.numberOfLoops = -1
        
        self.volumeLockLevel = volumeLockLevel

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        
        observer = avAudioSession.observe(\AVAudioSession.outputVolume, options: [.new], changeHandler: {sender, change in
            if !self.active { return }
            
            if change.newValue! > volumeLockLevel {
                self.volumeUpHandler?()
                MPVolumeView.setVolume(volumeLockLevel)
            } else if change.newValue! < volumeLockLevel {
                self.volumeDownHandler?()
                MPVolumeView.setVolume(volumeLockLevel)
            }
        })
    }
    
    @objc private func userDefaultsDidChange(){
        let wasPlaying = player.isPlaying
        if wasPlaying {
            player.stop()
        }
        
        if UserDefaults.standard.bool(forKey: "play_noise"){
            player = try! AVAudioPlayer(contentsOf:  URL.init(fileURLWithPath: Bundle.main.path(forResource: "Noise", ofType: "mp3")!))
        } else {
            player = try! AVAudioPlayer(contentsOf:  URL.init(fileURLWithPath: Bundle.main.path(forResource: "Silence", ofType: "mp3")!))
        }
        
        player.volume = 1
        player.numberOfLoops = -1
        
        if wasPlaying {
            player.play()
        }
    }
    
    func resumeAudio(){
        player.play()
        try? avAudioSession.setActive(true)
    }
    
    func suspendAudio(){
        player.stop()
        try? avAudioSession.setActive(false)
    }
    
    func received(event: UIEvent?) {
        switch event?.subtype.rawValue {
        case 103:
            playPauseHandler?()
        case 104, 109:
            skipHandler?()
        case 105, 106:
            backHandler?()
        default:
            break
        }
    }
}
