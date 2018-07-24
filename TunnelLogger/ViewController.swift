//
//  ViewController.swift
//  TunnelLogger
//
//  Created by Emanuel Mairoll on 17.07.18.
//  Copyright © 2018 Emanuel Mairoll. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    private let countLabel = UILabel()
    private let timeLabel = UILabel()
    private let stateLabel = UILabel()
    private let mainButton = UIButton(type: UIButton.ButtonType.system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let themeColor = UIColor(white: 0.7, alpha: 0.5)
        let themeBlur = UIBlurEffect(style: .regular)
        let textColor = UIColor.black
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]        
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        let upperBanner = UIVisualEffectView(effect: themeBlur)
        upperBanner.backgroundColor = themeColor
        upperBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upperBanner);
        upperBanner.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08, constant: 0).isActive = true
        upperBanner.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        upperBanner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        upperBanner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        let lowerBanner = UIVisualEffectView(effect: themeBlur)
        lowerBanner.backgroundColor = themeColor
        lowerBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowerBanner);
        lowerBanner.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08, constant: 0).isActive = true
        lowerBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lowerBanner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        lowerBanner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Tunnel Logger"
        titleLabel.textColor = textColor
        titleLabel.font = UIFont.systemFont(ofSize: 27, weight: .black)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: upperBanner.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: upperBanner.bottomAnchor).isActive = true

        let mainButtonBlur = UIVisualEffectView(effect: themeBlur)
        mainButtonBlur.backgroundColor = themeColor
        mainButtonBlur.translatesAutoresizingMaskIntoConstraints = false
        mainButtonBlur.layer.cornerRadius = 5
        mainButtonBlur.layer.masksToBounds = true;
        mainButtonBlur.isUserInteractionEnabled = false
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        updateButtonTitle(isLogging: false)
        mainButton.setTitleColor(textColor, for: .normal)
        mainButton.titleLabel!.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(mainButtonBlur)
        view.addSubview(mainButton)
        mainButtonBlur.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor).isActive = true
        mainButtonBlur.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor).isActive = true
        mainButtonBlur.widthAnchor.constraint(equalTo: mainButton.widthAnchor).isActive = true;
        mainButtonBlur.heightAnchor.constraint(equalTo: mainButton.heightAnchor).isActive = true;
        mainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainButton.widthAnchor.constraint(equalToConstant: 230).isActive = true;
        mainButton.heightAnchor.constraint(equalToConstant: 60).isActive = true;
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        updateCount(newCount: 0)
        countLabel.textColor = textColor
        countLabel.font = UIFont.systemFont(ofSize: 23)
        countLabel.textAlignment = .left
        view.addSubview(countLabel)
        countLabel.leftAnchor.constraint(equalTo: lowerBanner.leftAnchor, constant: 10).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: lowerBanner.bottomAnchor, constant: -10).isActive = true

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        updateTimer(newSeconds: 0)
        timeLabel.textColor = textColor
        timeLabel.font = UIFont.systemFont(ofSize: 23)
        timeLabel.textAlignment = .center
        view.addSubview(timeLabel)
        timeLabel.centerXAnchor.constraint(equalTo: lowerBanner.centerXAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: lowerBanner.bottomAnchor, constant: -10).isActive = true
        
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        updateState(inTunnel: false)
        stateLabel.textColor = textColor
        stateLabel.font = UIFont.systemFont(ofSize: 23)
        stateLabel.textAlignment = .right
        view.addSubview(stateLabel)
        stateLabel.rightAnchor.constraint(equalTo: lowerBanner.rightAnchor, constant: -10).isActive = true
        stateLabel.bottomAnchor.constraint(equalTo: lowerBanner.bottomAnchor, constant: -10).isActive = true

        let volumeView = MPVolumeView(frame: CGRect(x: 0, y: -100, width: 0, height: 0))
        volumeView.isHidden = false
        volumeView.alpha = 1
        view.addSubview(volumeView)

    }
    
    func addButtonPressHandler(target:Any, action:Selector){
        mainButton.addTarget(target, action: action, for: .touchUpInside)
    }

    
    public func updateCount(newCount:Int) {
        countLabel.text =  "\(newCount) Tunnels logged"
    }

    public func updateTimer(newSeconds:Int) {
        let hours = newSeconds / 3600
        let minutes = newSeconds / 60 % 60
        let seconds = newSeconds % 60
        timeLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

    public func updateState(inTunnel:Bool) {
        stateLabel.text = inTunnel ? "In Tunnel" : "Outside"
    }
    
    public func updateButtonTitle(isLogging:Bool){
        if isLogging{
            mainButton.setTitle("Stop Logging", for: .normal)
        } else {
            mainButton.setTitle("Start Logging", for: .normal)
        }
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        (volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider)?.value = volume
    }
}
