//
//  BPProgressView.swift
//  BPProgressView
//
//  Created by 沙庭宇 on 2019/12/2.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

enum BPProgressType {
    case horizontal // 水平的进度条
    case vertical   // 垂直的进度条
    case circle     // 圆形的进度条
    case semicircle // 半圆的进度条,支持指定半圆角度
}

class BPProgressView: UIView, CAAnimationDelegate {

    // TODO: ---- data ----
    // 用来保存当前进度
    var currentProgress: Float
    // 配置相关的协议
    var config: BPProgressConfig
    // 进度条最大长度
    var maxWidth = CGFloat.zero

    // TODO: ---- view ----
    var backgroundLayer = CALayer()
    var progressLayer   = CAShapeLayer()
    var sliderBar: UIView?

    init(_ config: BPProgressConfig, frame: CGRect) {
        self.config          = config
        self.sliderBar       = config.sliderBar
        self.currentProgress = config.progress
        super.init(frame: frame)
        self.createSubviews()
        self.bindData(config.progress)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(progressLayer)

        // ---- 背景色
        self.backgroundLayer.backgroundColor = self.config.tineColor.cgColor
        self.progressLayer.backgroundColor   = self.config.progressTineColor.cgColor

        // ---- 布局
        let backgroundX = config.backgourndMargin.left
        let backgroundY = config.backgourndMargin.top
        let backgroundW = self.frame.width - config.backgourndMargin.left - config.backgourndMargin.right
        let backgroundH = self.frame.height - config.backgourndMargin.top - config.backgourndMargin.bottom
        self.backgroundLayer.frame = CGRect(x: backgroundX, y: backgroundY, width: backgroundW, height: backgroundH)


        let progressW = backgroundLayer.frame.width - config.progressMargin.left - config.progressMargin.right
        let progressH = backgroundLayer.frame.height - config.progressMargin.top - config.progressMargin.bottom
        let progressX = backgroundLayer.frame.minX + config.progressMargin.left
        let progressY = backgroundLayer.frame.minY + config.progressMargin.top + progressH / 2
//        self.progressLayer.frame   = CGRect(x: progressX, y: progressY, width: progressH, height: progressH)
        self.maxWidth = progressW

        // ---- 添加路径
        let path = UIBezierPath()
        path.move(to: CGPoint(x: progressX, y: progressY))
        path.addLine(to: CGPoint(x: progressX + progressW, y: progressY))
        self.progressLayer.path        = path.cgPath
        self.progressLayer.lineWidth   = progressH
        self.progressLayer.lineJoin    = .round
        self.progressLayer.strokeColor = UIColor.blue.cgColor
        self.progressLayer.fillColor   = nil
        // ---- 圆角
        if config.isCorner {
            self.backgroundLayer.cornerRadius = backgroundH / 2
            self.progressLayer.cornerRadius   = progressH / 2
        }

        // ---- 滑动块
        if let sliderBar = self.sliderBar {
            self.addSubview(sliderBar)

            let sliderBarW = sliderBar.bounds.size.width
            let sliderBarH = sliderBar.bounds.size.height
            let sliderBarX = progressLayer.frame.maxX - sliderBarW / 2
            let sliderBarY = progressY - sliderBarH / 2
            sliderBar.frame = CGRect(x: sliderBarX, y: sliderBarY, width: sliderBarW, height: sliderBarH)
        }
        // ---- 添加滑动事件
        self.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.addGestureRecognizer(pan)
    }

    private func bindData(_ progress: Float) {
        self.play(progress)
        self.updateFrame(progress)
    }

    // TODO: ==== UIPanGestureRecognizer ====
    
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: self)

        let progress = (progressLayer.frame.width + point.x) / self.maxWidth
        self.play(Float(progress))
        if pan.state == .ended {
            self.updateFrame(Float(progress))
        }
    }

    // TODO: CAAnimationDelegate

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let keyPath = anim.value(forKeyPath: "keyPath") as? String, let progress = anim.value(forKey: "progress") as? Float else {
            return
        }
        if keyPath == "strokeEnd" {
            // 更新当前进度
            self.currentProgress = progress
        }
    }

    // TODO: ==== Tools ====
    private func play(_ progress: Float = .zero) {
        let progress = self.adjustProgress(progress)

        let duration = 0.1

        // 设置进度条进度动画
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue             = self.currentProgress
        strokeAnimation.toValue               = progress
        strokeAnimation.duration              = duration
        strokeAnimation.repeatCount           = 1
        strokeAnimation.fillMode              = .forwards
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.timingFunction        = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnimation.delegate              = self
        strokeAnimation.setValue(progress, forKey: "progress")
        self.progressLayer.add(strokeAnimation, forKey: "strokeAnimation")

        // 设置滑块进度动画
        if let sliderBar = self.sliderBar {
            let x = self.maxWidth * CGFloat(progress)
            let positionAnimation = CABasicAnimation(keyPath: "position.x")
            positionAnimation.toValue               = x
            positionAnimation.duration              = duration
            positionAnimation.repeatCount           = 1
            positionAnimation.fillMode              = .forwards
            positionAnimation.isRemovedOnCompletion = false
            positionAnimation.timingFunction        = CAMediaTimingFunction(name: .easeInEaseOut)
            sliderBar.layer.add(positionAnimation, forKey: nil)
        }
    }

    private func pause() {

    }

    private func stop() {

    }

    /// 更新进度条和滑块的Frame
    private func updateFrame(_ progress: Float) {
        let progress = self.adjustProgress(progress)
        let progressW = self.maxWidth * CGFloat(progress)
        self.progressLayer.frame = CGRect(x: progressLayer.frame.origin.x, y: progressLayer.frame.origin.y, width: progressW, height: progressLayer.frame.height)
        if let sliderBar = self.sliderBar {
            let sliderBarX = progressW - sliderBar.bounds.width / 2
            sliderBar.frame = CGRect(x: sliderBarX, y: sliderBar.frame.origin.y, width: sliderBar.frame.width, height: sliderBar.frame.height)
        }
    }

    private func adjustProgress(_ progress: Float) -> Float {
        if progress > 1.0 {
            return 1.0
        }
        if progress < 0.0 {
            return 0.0
        }
        return progress
    }
}
