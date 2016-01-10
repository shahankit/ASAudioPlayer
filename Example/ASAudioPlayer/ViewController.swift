//
//  ViewController.swift
//  ASAudioPlayer
//
//  Created by Ankit Shah on 01/10/2016.
//  Copyright (c) 2016 Ankit Shah. All rights reserved.
//

import UIKit
import ASAudioPlayer

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		let url = NSURL(string: "http://www.samisite.com/sound/cropShadesofGrayMonkees.mp3")!
		// Audio url credits: http://www.samisite.com/test-csb2nf/audio.htm
		let audioPlayer = ASAudioPlayer(frame: CGRectMake(0, self.view.frame.height / 2 - 50, self.view.frame.width, 100))
		audioPlayer.setUrl(url)
		self.view.addSubview(audioPlayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

