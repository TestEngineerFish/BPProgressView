//
//  Extension.swift
//  BPProgressView
//
//  Created by 沙庭宇 on 2019/12/2.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import UIKit

public extension UIColor {
    /// 十六进制颜色值
    /// - parameter hex: 十六进制值,例如: 0x000fff
    /// - parameter alpha: 透明度
    class func hex(_ hex: UInt32, alpha: CGFloat = 1.0) -> UIColor {
        if hex > 0xFFF {
            let divisor = CGFloat(255)
            let red     = CGFloat((hex & 0xFF0000) >> 16) / divisor
            let green   = CGFloat((hex & 0xFF00  ) >> 8)  / divisor
            let blue    = CGFloat( hex & 0xFF    )        / divisor
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            let divisor = CGFloat(15)
            let red     = CGFloat((hex & 0xF00) >> 8) / divisor
            let green   = CGFloat((hex & 0x0F0) >> 4) / divisor
            let blue    = CGFloat( hex & 0x00F      ) / divisor
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

/// 渐变色的方向枚举
public enum GradientDirectionType: Int {
    case horizontal = 0 /// 水平(左->右)
    case vertical   = 1 /// 垂直(上->下)
    case leftTop    = 2 /// 斜角(左上->右下)
    case leftBottom = 3 /// 斜角(左下->右上)
}

// MARK: - 渐变色
extension CALayer {
    /// 根据方向,设置渐变色
    /// - parameter colors: 渐变的颜色数组
    /// - parameter direction: 渐变方向的枚举对象
    /// - note: 设置前,一定要确定当前View的高宽!!!否则无法准确的绘制
    public func setGradient(colors: [UIColor], direction: GradientDirectionType) {
        switch direction {
        case .horizontal:
            setGradient(colors: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        case .vertical:
            setGradient(colors: colors, startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
        case .leftTop:
            setGradient(colors: colors, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        case .leftBottom:
            setGradient(colors: colors, startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0))
        }
    }

    /// 设置渐变色
    /// - parameter colors: 渐变颜色数组
    /// - parameter locations: 逐个对应渐变色的数组,设置颜色的渐变占比,nil则默认平均分配
    /// - parameter startPoint: 开始渐变的坐标(控制渐变的方向),取值(0 ~ 1)
    /// - parameter endPoint: 结束渐变的坐标(控制渐变的方向),取值(0 ~ 1)
    @discardableResult
    public func setGradient(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint, endPoint: CGPoint) -> CAGradientLayer {
        /// 设置渐变色
        func _setGradient(_ layer: CAGradientLayer) {
            // self.layoutIfNeeded()
            var colorArr = [CGColor]()
            for color in colors {
                colorArr.append(color.cgColor)
            }

            /** 将UI操作的事务,先打包提交,防止出现视觉上的延迟展示,
             * 但如果在提交的线程中还有其他UI操作,则这些UI操作会被隐式的包在CATransaction事务中
             * 则当前显式创建的CATransaction则还是会等到这个UI操作的事务结束后,才会展示,毕竟嵌套了嘛
             * 如果一定要立马展示,可以结束之前的UI操作,强制展示:CATransaction.flush(),缺点就是会造成其他UI操作的异常
             */
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.frame = self.bounds
            CATransaction.commit()

            layer.colors     = colorArr
            layer.locations  = locations
            layer.startPoint = startPoint
            layer.endPoint   = endPoint
        }

        //查找是否有已经存在的渐变色Layer
        var kCAGradientLayerType = CAGradientLayerType.axial
        if let gradientLayer = objc_getAssociatedObject(self, &kCAGradientLayerType) as? CAGradientLayer {
            // 清除渐变颜色
            gradientLayer.removeFromSuperlayer()
        }
        let gradientLayer = CAGradientLayer()
        self.insertSublayer(gradientLayer , at: 0)
        _setGradient(gradientLayer)
        // 添加渐变色属性到当前Layer
        objc_setAssociatedObject(self, &kCAGradientLayerType, gradientLayer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return gradientLayer
    }
}
