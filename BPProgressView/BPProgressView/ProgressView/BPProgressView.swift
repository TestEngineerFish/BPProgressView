//
//  BPProgressView.swift
//  BPProgressView
//
//  Created by 沙庭宇 on 2019/12/2.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

protocol BPProgressViewProtocol: NSObjectProtocol {
    func updateProgress(_ progress: Float)
}

class BPHorProgressView: BPBaseProgressView {

    override func createSubviews() {
        super.createSubviews()
        self.maxWidth = self.progressLayer.frame.width
        // ---- 添加路径
        let pathOriginX = self.progressLayer.frame.origin.x
        let pathOriginY = self.progressLayer.frame.midY
        let pathToX = self.progressLayer.frame.maxX
        let pathToY = self.progressLayer.frame.midY
        let path = UIBezierPath()
        path.move(to: CGPoint(x: pathOriginX, y: pathOriginY))
        path.addLine(to: CGPoint(x: pathToX, y: pathToY))
        self.progressMask.path = path.cgPath
    }

    override func bindData() {
        super.bindData()
        self.lastWidth = self.maxWidth * CGFloat(config.progress)
        self.play(config.progress)
        self.updateFrame(config.progress)
    }

}
