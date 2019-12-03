//
//  ViewController.swift
//  BPProgressView
//
//  Created by 沙庭宇 on 2019/12/2.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.createProgressView()
    }

    private func createProgressView() {
        let sliderView = UIView()
        sliderView.backgroundColor = UIColor.purple
        sliderView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        sliderView.layer.cornerRadius = sliderView.frame.height / 2
        var config = BPProgressConfig()
        config.progress = 0.7
//        config.sliderBar = sliderView
        let frame = CGRect(x: 0, y: 0, width: 200, height: 10)
        let progressView = BPProgressView(config, frame: frame)
        progressView.center = self.view.center
        self.view.addSubview(progressView)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

    }
}

