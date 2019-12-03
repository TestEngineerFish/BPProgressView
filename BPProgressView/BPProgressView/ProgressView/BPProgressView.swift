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

protocol BPProgressViewProtocol: NSObjectProtocol {
    func updateProgress(_ progress: Float)
}

class BPProgressView: UIView {

    // TODO: ---- data ----
    // 用来保存当前进度
    var currentProgress: Float
    // 配置相关的协议
    var config: BPProgressConfig
    // 进度条最大长度
    var maxWidth = CGFloat.zero
    // 最后一次更新的进度条长度
    var lastWidth = CGFloat.zero
    // 协议对象
    var delegate: BPProgressViewProtocol?

    // TODO: ---- view ----
    var backgroundLayer = CAGradientLayer()
    var progressLayer   = CAGradientLayer()
    var progressMask    = CAShapeLayer()

    init(_ config: BPProgressConfig, frame: CGRect) {
        self.config          = config
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
        let progressY = backgroundLayer.frame.minY + config.progressMargin.top
        self.progressLayer.frame   = CGRect(x: progressX, y: progressY, width: progressW, height: progressH)
        self.maxWidth = progressW

        // ---- 添加路径
        let path = UIBezierPath()
        path.move(to: CGPoint(x: progressX, y: progressY + progressH / 2))
        path.addLine(to: CGPoint(x: progressX + progressW, y: progressY + progressH / 2))

        // ---- 设置遮罩
        self.progressMask.path        = path.cgPath
        self.progressMask.lineWidth   = progressH
        self.progressMask.duration    = 0.01
        self.progressMask.strokeColor = UIColor.yellow.cgColor
        self.progressMask.fillColor   = nil
        self.progressLayer.mask       = self.progressMask

        // ---- 设置圆角
        if config.isCorner {
            self.backgroundLayer.cornerRadius = backgroundH / 2
            self.progressLayer.cornerRadius   = progressH / 2
            self.progressMask.lineCap         = .round
        }

        // ---- 滑动块
        if let sliderBar = self.config.sliderBar {
            self.addSubview(sliderBar)
            let sliderBarW = sliderBar.bounds.size.width
            let sliderBarH = sliderBar.bounds.size.height
            let sliderBarX = progressLayer.frame.maxX - sliderBarW / 2
            let sliderBarY = progressLayer.frame.midY - sliderBarH / 2
            sliderBar.frame = CGRect(x: sliderBarX, y: sliderBarY, width: sliderBarW, height: sliderBarH)
        }
        // ---- 添加滑动事件
        self.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.addGestureRecognizer(pan)
    }

    private func bindData(_ progress: Float) {
        self.lastWidth = self.maxWidth * CGFloat(progress)
        self.play(progress)
        self.updateFrame(progress)
    }

    // TODO: ==== UIPanGestureRecognizer ====

    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: self)

        let progress = (self.lastWidth + point.x) / self.maxWidth
        self.play(Float(progress))
        if pan.state == .ended {
            self.updateFrame(Float(progress))
        }
    }

    // TODO: ==== Tools ====
    private func play(_ progress: Float = .zero) {
        let progress = self.adjustProgress(progress)

        let duration = 0.1

        // 设置进度条进度动画
        self.progressMask.strokeEnd = CGFloat(progress)

        // 设置滑块进度动画
        if let sliderBar = self.config.sliderBar {
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
        if let sliderBar = self.config.sliderBar {
            let sliderBarX = progressW - sliderBar.bounds.width / 2
            sliderBar.frame = CGRect(x: sliderBarX, y: sliderBar.frame.origin.y, width: sliderBar.frame.width, height: sliderBar.frame.height)
        }
        self.lastWidth = progressW
        self.delegate?.updateProgress(progress)
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
