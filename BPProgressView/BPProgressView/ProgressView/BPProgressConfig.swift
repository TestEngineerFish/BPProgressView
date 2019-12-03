//
//  BPProgressConfig.swift
//  BPProgressView
//
//  Created by 沙庭宇 on 2019/12/2.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

/// 配置模型
struct BPProgressConfig {
    /// 进度颜色
    var progressTineColor = UIColor.orange
    /// 背景外边距
    var backgourndMargin = UIEdgeInsets.zero
    /// 进度条外边距
    var progressMargin = UIEdgeInsets.zero
    /// 背景颜色
    var tineColor  = UIColor.gray
    /// 背景边框颜色
    var boardColor = UIColor.clear
    /// 背景边框宽度
    var boardWidth = Float.zero
    /// 进度设置
    var progress   = Float.zero
    /// 圆角设置
    var isCorner   = true
    /// 进度滑块
    var sliderBar: UIView?

}
