//
//  ASVideoView.swift
//  BaiSiApp
//
//  Created by ashen on 16/4/6.
//  Copyright © 2016年 Ashen<http://www.devashen.com>. All rights reserved.
//

import UIKit

import MediaPlayer

class ASVideoView: UIView {
    
    @IBOutlet weak var lblPlayCount: UILabel!
    
    @IBOutlet weak var lblPlayTime: UILabel!
    
    @IBOutlet weak var bgkImageView: UIImageView!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var touchView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var logoBgk: UIImageView!
    
    @IBOutlet weak var controlsVIew: UIView!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var lblCurrentTime: UILabel!
    
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var controlStart: UIButton!
    
    let player = MPMoviePlayerController()
    var controlsHidden = true
    var timer:NSTimer!
    var currentTimer:NSTimer!
    var touchTime:NSDate!
    var isFirstTouch = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(stateChanged), name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(finished), name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(start), name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: nil)
    }
    
    
    class func videoView() -> ASVideoView {
        return NSBundle.mainBundle().loadNibNamed("ASVideoView", owner: nil, options: nil)[0] as! ASVideoView
    }
    
    // MARK: -
    var videoModel:ASVideoModel! {
        didSet {
        
            player.contentURL = NSURL(string: videoModel.video[0])
            player.view.frame = self.bounds
            player.scalingMode = .AspectFit;
            player.controlStyle = .None
            player.backgroundView.backgroundColor = UIColor.lightGrayColor()
            self.addSubview(player.view)
            self.sendSubviewToBack(player.view)
            
            bgkImageView.kf_setImageWithURL(NSURL(string: videoModel.thumbnail.count > 0 ? videoModel.thumbnail[0]: "")!)
            lblPlayCount.text = "\(videoModel.playcount) 播放"
            lblPlayTime.text = getNormalTimeStyle(String(videoModel.duration))
            logoBgk.hidden = true
            lblTotalTime.text = getNormalTimeStyle(String(videoModel.duration))
            
            lblCurrentTime.text = "00:00"
            slider.setThumbImage(UIImage(named: "voice-play-progress-icon"), forState: .Normal)
            slider.value = 0.0
            viewsHidden(false)
            isFirstTouch = false
            indicator.hidden = true
            controlsHidden = true
            controlStart.setImage(UIImage(named: "playButtonPause"), forState: .Normal)
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func tapPlayPauseAction(sender: AnyObject) {
        
        touchTime = NSDate()
        if player.playbackState == .Playing {
            var frame = controlsVIew.frame
            if controlsHidden {
                frame.origin.y -= 55
                if timer != nil {
                    timer.invalidate()
                }
                timer =  NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(autoHiddenControls), userInfo: nil, repeats: true)
                
            } else {
                frame.origin.y += 55
            }
            controlsHidden = !controlsHidden
            UIView.animateWithDuration(0.3) {
                self.controlsVIew.frame = frame
            }
        } else {
            if !isFirstTouch{
                indicator.hidden = false
                indicator.startAnimating()
                player.play()
            }
            isFirstTouch = true
        }
    }
    
    @IBAction func btnStartAction(sender: AnyObject) {
        if player.playbackState == .Playing {
            (sender as! UIButton).setImage(UIImage(named: "voice-play-start"), forState: .Normal)
            player.pause()
        } else {
            (sender as! UIButton).setImage(UIImage(named: "playButtonPause"), forState: .Normal)
            player.play()
        }
    }
    
    @IBAction func btnFullScreenAction(sender: AnyObject) {
        
    }
    
    @IBAction func btnAlertAction(sender: AnyObject) {
        
    }
    
    @IBAction func btnDownAction(sender: AnyObject) {
        
    }
    
    //MARK: - private Methods
    @objc private func stateChanged() {
        
        switch (self.player.playbackState) {
        case .Playing:
            if currentTimer != nil {
                currentTimer.invalidate()
            }
            currentTimer =  NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: #selector(changeCurrentTimeLbl), userInfo: nil, repeats: true)
            viewsHidden(true)
            break;
        case .Paused:
            if currentTimer != nil {
                currentTimer.invalidate()
            }
            viewsHidden(true)
            break;
        default:
            break;
        }
    }
    
    @objc private func finished() {
        self.sendSubviewToBack(player.view)
        isFirstTouch = false
        viewsHidden(false)
        bgkImageView.hidden = false
        if currentTimer != nil {
            currentTimer.invalidate()
        }
        if !controlsHidden {
            var frame = self.controlsVIew.frame
            frame.origin.y += 55
            UIView.animateWithDuration(0.3) {
                self.controlsVIew.frame = frame
            }
            self.controlsHidden = true
        }
    }
    
    func autoHiddenControls() {
        if controlsHidden || player.playbackState == .Paused {
            return
        }
        if NSDate().timeIntervalSinceDate(touchTime) > 5.0 {
            var frame = self.controlsVIew.frame
            frame.origin.y += 55
            UIView.animateWithDuration(0.3) {
                self.controlsVIew.frame = frame
            }
            self.controlsHidden = true
            timer.invalidate()
        }
    }
    
    func changeCurrentTimeLbl() {
        if player.currentPlaybackTime.isNaN  {
            return
        }
        lblCurrentTime.text = getNormalTimeStyle(String(Int(player.currentPlaybackTime)))
        slider.setValue((Float)(player.currentPlaybackTime / player.duration), animated: true)
        slider.setMinimumTrackImage(UIImage(named: "voice-play-progress"), forState: .Normal)
        indicator.hidden = true
        bgkImageView.hidden = true
    }
    
    func getNormalTimeStyle(time:String)->String {
        var result = "00:00"
        let timeInterval:Int! = Int(time)
        if timeInterval < 60 {
            result = String(format:"00:%02d", timeInterval!)
        } else if timeInterval < 3600 {
           result = String(format: "%02d:%02d", timeInterval / 60, timeInterval % 60)
        }
        return result
    }
    
    private func viewsHidden(hidden:Bool) {
        btnPlay.hidden = hidden
        lblPlayTime.hidden = hidden
        lblPlayCount.hidden = hidden
    }
}
