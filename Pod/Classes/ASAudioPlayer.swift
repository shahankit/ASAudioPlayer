//
//  ASAudioPlayer.swift
//  Pods
//
//  Created by Ankit Shah on 10/01/16.
//
//

import UIKit
import AVFoundation

@objc protocol AudioPlayerDelegate: class {
	optional func updateSeekTime(seekTime: Double)
	optional func playButtonPressed()
	optional func playBackStopped()
}

public class ASAudioPlayer: UIView {
	var playButton: UIButton!
	var emptyView: UIView!
	var filledView: UIView!
	var overlayView: UIView!
	var sliderView: UIView!
	var sliderCircle: UIImageView!
	var currentTimeLabel: UILabel!
	var totalTimeLabel: UILabel!
	
	var audioPlaying: Bool = false
	var audioPlayer: AVPlayer!
	var audioURL: NSURL!
	var sliderMinX: CGFloat!
	var sliderMaxX: CGFloat!
	var seekTime: Double!
	var totalTime: Double!
	var stopUpdateView: Bool = false
	var updateBlock: (CMTime -> Void)!
	var layoutSubviewsCalled: Bool = false
	
	weak var delegate: AudioPlayerDelegate!
	
	private let kInternalPadding: CGFloat = 8.0
	private let kPaddingBig: CGFloat = 16.0
	private let kPlaybuttonHeight: CGFloat = 48.0
	private let kProgressBarHeight: CGFloat = 6.0
	private let kProgressBarWrapperHeight: CGFloat = 12.0
	private let kSliderCircleHeight: CGFloat = 12.0
	private let kSliderCircleWrapperHeight: CGFloat = 24.0
	private let kFontSize: CGFloat = 10.0
	
	public var kAudioPlayerTextColor = UIColor(red: 185.0/255.0, green: 186.0/255.0, blue: 188.0/255.0, alpha: 1.0)
	public var kAudioPlayerSeekbarColor = UIColor(red: 57.0/255.0, green: 61.0/255.0, blue: 62.0/255.0, alpha: 1.0)
	public var kAudioPlayerFilledColor = UIColor(red: 28.0/255.0, green: 138.0/255.0, blue: 203.0/255.0, alpha: 1.0)
	public var kAudioPlayerBackgroudColor = UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
	public var kBackgroundColor = UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
	
	public var playImage: UIImage!
	public var pauseImage: UIImage!
	public var sliderImage: UIImage!
	
	override public func layoutSubviews() {
		if layoutSubviewsCalled {
			return;
		} else {
			layoutSubviewsCalled = true
			playButton.frame = CGRectMake(kInternalPadding, self.frame.height/2 - kPlaybuttonHeight/2, kPlaybuttonHeight, kPlaybuttonHeight)
			
			let contentHeight = kSliderCircleWrapperHeight/2 + kProgressBarHeight/2 + kInternalPadding + kFontSize + 2
			
			//All views derive y co-ordinte from emptyView
			emptyView.frame = CGRectMake(playButton.frame.origin.x + playButton.frame.width + kPaddingBig, self.frame.height/2 - contentHeight/2 + (kSliderCircleWrapperHeight - kProgressBarHeight)/2, self.frame.width - kInternalPadding - playButton.frame.width - kPaddingBig - kInternalPadding, kProgressBarHeight)
			
			filledView.frame = CGRectMake(emptyView.frame.origin.x, emptyView.frame.origin.y, 0, kProgressBarHeight)
			
			overlayView.frame = CGRectMake(emptyView.frame.origin.x, emptyView.frame.origin.y + emptyView.frame.height/2 - kProgressBarWrapperHeight/2, emptyView.frame.width, kProgressBarWrapperHeight)
			
			sliderMinX = emptyView.frame.origin.x - kSliderCircleWrapperHeight/2
			sliderMaxX = sliderMinX + emptyView.frame.width
			
			sliderView.frame = CGRectMake(emptyView.frame.origin.x - kSliderCircleWrapperHeight/2, emptyView.frame.origin.y + emptyView.frame.height/2 - kSliderCircleWrapperHeight/2, kSliderCircleWrapperHeight, kSliderCircleWrapperHeight)
			
			sliderCircle.frame = CGRectMake(kSliderCircleWrapperHeight/2 - kSliderCircleHeight/2, kSliderCircleWrapperHeight/2 - kSliderCircleHeight/2, kSliderCircleHeight, kSliderCircleHeight)
			
			currentTimeLabel.frame = CGRectMake(emptyView.frame.origin.x, emptyView.frame.origin.y + emptyView.frame.height + kInternalPadding, emptyView.frame.width/2, kFontSize + 2)
			
			totalTimeLabel.frame = CGRectMake(emptyView.frame.origin.x + emptyView.frame.width/2, currentTimeLabel.frame.origin.y, emptyView.frame.width/2, kFontSize + 2)
		}
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.initSubviews()
	}
	
	init () {
		super.init(frame: CGRectZero)
		self.initSubviews()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initSubviews()
	}
	
	func initSubviews() {
		playImage = self.imageNamedFromPodBundle("play_button.png")
		pauseImage = self.imageNamedFromPodBundle("pause_button.png")
		sliderImage = self.imageNamedFromPodBundle("slider_circle.png")
		
		playButton = UIButton()
		playButton.setImage(playImage, forState: UIControlState.Normal)
		playButton.addTarget(self, action: Selector("playButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
		self.addSubview(playButton)
		
		//All views derive y co-ordinte from emptyView
		emptyView = UIView()
		emptyView.layer.cornerRadius = kProgressBarHeight/2
		emptyView.backgroundColor = kAudioPlayerSeekbarColor
		self.addSubview(emptyView)
		
		filledView = UIView()
		filledView.backgroundColor = kAudioPlayerFilledColor
		filledView.layer.cornerRadius = kProgressBarHeight/2
		self.addSubview(filledView)
		
		overlayView = UIView()
		overlayView.backgroundColor = UIColor.clearColor()
		let tapGesture = UITapGestureRecognizer(target: self, action: Selector("progressBarTapped:"))
		overlayView.addGestureRecognizer(tapGesture)
		self.addSubview(overlayView)
		
		sliderView = UIView()
		sliderView.backgroundColor = UIColor.clearColor()
		let panGesture = UIPanGestureRecognizer(target: self, action: Selector("moveSlider:"))
		panGesture.maximumNumberOfTouches = 1
		sliderView.addGestureRecognizer(panGesture)
		self.addSubview(sliderView)
		
		sliderCircle = UIImageView()
		sliderCircle.image = sliderImage
		sliderCircle.contentMode = UIViewContentMode.ScaleAspectFit
		sliderView.addSubview(sliderCircle)
		
		currentTimeLabel = UILabel()
		currentTimeLabel.font = UIFont.systemFontOfSize(kFontSize)
		currentTimeLabel.text = "00:00"
		currentTimeLabel.textColor = kAudioPlayerTextColor
		self.addSubview(currentTimeLabel)
		
		totalTimeLabel = UILabel()
		totalTimeLabel.font = UIFont.systemFontOfSize(kFontSize)
		totalTimeLabel.text = "00:00"
		totalTimeLabel.textColor = kAudioPlayerTextColor
		totalTimeLabel.textAlignment = NSTextAlignment.Right
		self.addSubview(totalTimeLabel)
		
		updateBlock = { (time: CMTime) -> Void in
			if self.audioPlayer != nil {
				if self.totalTime == 0.0 {
					self.totalTime = CMTimeGetSeconds(self.audioPlayer.currentItem!.asset.duration)
					if self.totalTime == 0.0 {
						return
					}
					let totalSeconds = Int(self.totalTime)
					self.totalTimeLabel.text = String(format: "%02d:%02d", totalSeconds/60, totalSeconds%60)
				}
				let currentTimeLabel = CMTimeGetSeconds(time)
				if !self.stopUpdateView {
					self.filledView.frame.size.width = self.emptyView.frame.width * CGFloat(currentTimeLabel / self.totalTime)
					self.sliderView.frame.origin.x = self.sliderMinX + self.filledView.frame.width
				}
				let seconds = Int(CMTimeGetSeconds(time))
				self.currentTimeLabel.text = String(format: "%02d:%02d", seconds/60, seconds%60)
				if currentTimeLabel == self.totalTime {
					self.playbackFinished()
				}
			}
		}
		
		self.backgroundColor = kBackgroundColor
	}
	
	//MARK: Callback methods
	func playButtonPressed() {
		delegate?.playButtonPressed?()
		if audioPlaying {
			audioPlayer?.pause()
			
			audioPlaying = false
			playButton.setImage(playImage, forState: UIControlState.Normal)
		}
		else {
			if audioPlayer.error != nil {
				print(audioPlayer.error, terminator: "")
				return
			}
			audioPlayer.play()
			
			audioPlaying = true
			playButton.setImage(pauseImage, forState: UIControlState.Normal)
		}
	}
	
	func progressBarTapped(sender: UITapGestureRecognizer) {
		let newX = sender.locationInView(self).x - kSliderCircleWrapperHeight/2
		updateSlider(newX)
		seekPlayer(sliderView.frame.origin.x - sliderMinX)
	}
	
	func moveSlider(recognizer: UIPanGestureRecognizer) {
		if recognizer.state == UIGestureRecognizerState.Began {
			self.stopUpdateView = true
			UIView.animateWithDuration(0.2, animations: { () -> Void in
				self.sliderCircle.frame = CGRectMake(0, 0, self.kSliderCircleWrapperHeight, self.kSliderCircleWrapperHeight)
			})
		}
		else if recognizer.state == UIGestureRecognizerState.Ended {
			seekPlayer(sliderView.frame.origin.x - sliderMinX)
			UIView.animateWithDuration(0.2,
				animations: { () -> Void in
					self.sliderCircle.frame = CGRectMake(self.kSliderCircleWrapperHeight/2 - self.kSliderCircleHeight/2, self.kSliderCircleWrapperHeight/2 - self.kSliderCircleHeight/2, self.kSliderCircleHeight, self.kSliderCircleHeight)
				},
				completion: { (completed: Bool) -> Void in
					if completed {
						self.stopUpdateView = false
					}
			})
		}
		else {
			let newX = recognizer.locationInView(self).x - kSliderCircleWrapperHeight/2
			updateSlider(newX)
		}
	}
	
	//MARK: - Helper methods
	func updateSlider(newX: CGFloat) {
		if newX >= sliderMaxX {
			sliderView.frame.origin.x = sliderMaxX
			filledView.frame.size.width = sliderMaxX - sliderMinX
		}
		else if newX <= sliderMinX {
			sliderView.frame.origin.x = sliderMinX
			filledView.frame.size.width = 0
		}
		else {
			sliderView.frame.origin.x = newX
			filledView.frame.size.width = newX - sliderMinX
		}
	}
	
	func seekPlayer(position: CGFloat) {
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			if self.audioPlayer != nil && self.audioPlayer.status == AVPlayerStatus.ReadyToPlay && self.audioPlayer.currentItem != nil && self.audioPlayer.currentItem!.status == AVPlayerItemStatus.ReadyToPlay {
				let seconds = CGFloat(self.totalTime) * position / self.emptyView.frame.width
				let seekTime = CMTimeMakeWithSeconds(Double(seconds), 600)
				self.audioPlayer.seekToTime(seekTime)
			}
		})
	}
	
	func playbackFinished() {
		delegate?.playBackStopped?()
		audioPlaying = false
		updateSlider(sliderMinX)
		seekPlayer(0)
		playButton.setImage(playImage, forState: UIControlState.Normal)
		currentTimeLabel.text = "00:00"
	}
	
	public func pause() {
		if audioPlaying {
			audioPlayer?.pause()
			
			audioPlaying = false
			playButton.setImage(playImage, forState: UIControlState.Normal)
		}
	}
	
	public func replaceURL(url: NSURL) {
		audioURL = url
		let avPlayerItem = AVPlayerItem(URL: audioURL)
		audioPlayer.replaceCurrentItemWithPlayerItem(avPlayerItem)
		totalTime = 0.0
	}
	
	public func setUrl(url: NSURL) {
		if audioURL == nil {
			audioURL = url
			totalTime = 0.0
			
			audioPlayer = AVPlayer(URL: audioURL)
			audioPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 10),
				queue: dispatch_get_main_queue(),
				usingBlock: updateBlock)
		} else {
			self.replaceURL(url)
		}
	}
	
	func setPlay(play: Bool) {
		if !play {
			pause()
		}
	}
	
	func imageNamedFromPodBundle(imageName: String) -> UIImage? {
		let podBundle = NSBundle(forClass: self.classForCoder)
		
		if let bundleUrl = podBundle.URLForResource("ASAudioPlayer", withExtension: "bundle") {
			if let bundle = NSBundle(URL: bundleUrl) {
				let image = UIImage(named: imageName, inBundle: bundle, compatibleWithTraitCollection: nil)
				return image;
				
			} else {
				return nil
				
			}
		} else {
			return nil
		}
	}
	
	deinit {
		if audioPlayer != nil && audioPlayer.currentItem != nil {
			delegate?.updateSeekTime?(CMTimeGetSeconds(audioPlayer.currentItem!.duration))
		}
		currentTimeLabel?.removeFromSuperview()
		currentTimeLabel = nil
		totalTimeLabel?.removeFromSuperview()
		totalTimeLabel = nil
	}
}
