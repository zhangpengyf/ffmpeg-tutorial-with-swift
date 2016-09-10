//
//  ViewController.swift
//  ffmpeg-tutorial-with-swift
//
//  Created by zhangpeng on 9/9/16.
//  Copyright © 2016 zhangpeng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func RunTutorial1(sender: AnyObject) {
        print("RunTutorial1 start")
        Tutorial1().main("../../movie.mkv")
        print("RunTutorial1 stop")
    }
    
    @IBAction func RunTutorial2(sender: AnyObject) {
        print("RunTutorial2 start")
        print("RunTutorial2 stop")
    }
    
    @IBAction func RunTutorial3(sender: AnyObject) {
        print("RunTutorial3 start")
        print("RunTutorial3 stop")
    }
    
    @IBAction func RunTutorial4(sender: AnyObject) {
        print("RunTutorial4 start")
        print("RunTutorial4 stop")
    }
    
    @IBAction func RunTutorial5(sender: AnyObject) {
        print("RunTutorial5 start")
        print("RunTutorial5 stop")
    }
    
    @IBAction func RunTutorial6(sender: AnyObject) {
        print("RunTutorial6 start")
        print("RunTutorial6 stop")
    }

    @IBAction func RunTutorial7(sender: AnyObject) {
        print("RunTutorial7 start")
        print("RunTutorial7 stop")
    }

}

