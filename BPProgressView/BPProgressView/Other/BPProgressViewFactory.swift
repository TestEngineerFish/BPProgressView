//
//  BPProgressViewFactory.swift
//  BPProgressView
//
//  Created by 沙庭宇 on 2019/12/3.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

struct BPProgressViewFactory {

    /// 工厂函数,根据类型,返回对应进度条视图
    static func buildView(_ config: BPProgressConfig, frame: CGRect) -> BPBaseProgressView {
        switch config.type {
        case .horizontal:
            return BPHorProgressView(config, frame: frame)
        case .vertical:
            return BPHorProgressView(config, frame: frame)
        case .circle:
            return BPHorProgressView(config, frame: frame)
        case .semicircle:
            return BPHorProgressView(config, frame: frame)
        }
    }
}
