//
//  DZMProgressView.swift
//  DZMPhotoBrowser
//
//  Created by 邓泽淼 on 16/7/27.
//  Copyright © 2016年 DZM. All rights reserved.
//

/**
 样式
 
 - Annular: Annular description
 - Circle:  Circle description
 - Pie:     Pie description
 */
enum SMProgressType:Int {
    case Annular
    case Circle
    case Pie
}

import UIKit

/// 该对象可使用单利全局控制 也可以单独创建使用
class DZMProgressAppearance: NSObject {
    
    // 样式
    var type:SMProgressType! = .Circle
    
    // 是否显示 百分比文字   只对 DZMProgressTypeAnnular 和 DZMProgressTypeCircle 会有效
    var showPercentage:Bool = true
    
    // 进度颜色
    var progressTintColor:UIColor!
    
    // 背景颜色
    var backgroundTintColor:UIColor!
    
    // 进度字体颜色
    var percentageTextColor:UIColor!
    
    // 设置该属性颜色 会一起设置 progressTintColor backgroundTintColor percentageTextColor
    var schemeColor:UIColor! {
        didSet{
            setupColor()
        }
    }
    
    // 进度文字字体
    var percentageTextFont:UIFont = UIFont.systemFontOfSize(10)
    
    // 进度文字偏移
    var percentageTextOffset:CGPoint = CGPointZero
    
    //  初始化
    override init() {
        super.init()
        schemeColor = UIColor.whiteColor()
        setupColor()
    }
    
    // 设置颜色
    func setupColor() {
        
        progressTintColor = UIColor(CGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)!)
        backgroundTintColor = UIColor(CGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 0.1)!)
        percentageTextColor = UIColor(CGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)!)
    }
    
    // 获取单利对象
    class var progressAppearance : DZMProgressAppearance {
        struct Static {
            static let instance : DZMProgressAppearance = DZMProgressAppearance()
        }
        return Static.instance
    }
}

class DZMProgressView: UIView {

    /// 进度
    var progress:Float = 0
    
    /// 配置
    var progressAppearance:DZMProgressAppearance = DZMProgressAppearance.progressAppearance
    
    // 初始化
    convenience init(){
        self.init(frame: CGRectMake(0, 0, 40, 40))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        opaque = false
        registerForKVO()
    }
    
    deinit {
        
        unregisterFromKVO()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -- KVO
    
    func registerForKVO() {
        
        for keyPath in observableKeypaths() {
            
            addObserver(self, forKeyPath: keyPath, options: NSKeyValueObservingOptions.New, context: nil)
        }
    }
    
    func unregisterFromKVO() {
       
        for keyPath in observableKeypaths() {
        
            removeObserver(self, forKeyPath: keyPath)
            
        }
    }
    
    func observableKeypaths() ->[String] {
        return ["progressAppearance","progress"]
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        setNeedsDisplay()
    }
    
    // MARK: -- Drawing
    
    override func drawRect(rect: CGRect) {
        
        let allRect:CGRect = bounds
        
        let context = UIGraphicsGetCurrentContext()!
        
        let appearance:DZMProgressAppearance = progressAppearance
        
        if appearance.type == .Annular {
           
            // 1
            let lineWidth:CGFloat = 1
            
            let processBackgroundPath:UIBezierPath = UIBezierPath()
            
            processBackgroundPath.lineWidth = lineWidth
            
            processBackgroundPath.lineCapStyle = .Round
            
            let center:CGPoint = CGPointMake(bounds.size.width/2, bounds.size.height/2)
            
            let radius:CGFloat = (bounds.size.width - lineWidth)/2
            
            let startAngle:CGFloat = -(CGFloat(M_PI) / 2)
            
            var endAngle = (2 * CGFloat(M_PI) + startAngle)
            
            processBackgroundPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
           
            appearance.backgroundTintColor.set()
           
            processBackgroundPath.stroke()
            
            // 2
            let processPath:UIBezierPath = UIBezierPath()
            
            processPath.lineCapStyle = .Round
            
            processPath.lineWidth = lineWidth
            
            endAngle = (CGFloat(progress) * 2 * CGFloat(M_PI)) + startAngle
            
            processPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            appearance.progressTintColor.set()
            
            processPath.stroke()
            
            // 3
            if appearance.showPercentage {
                
                drawTextInContext(context)
            }
            
        }else if appearance.type == .Circle {
            
            // 1
            let colorBackAlpha:CGColorRef = CGColorCreateCopyWithAlpha(appearance.backgroundTintColor.CGColor, 0.05)!
            
            let colorProgressAlpha:CGColorRef = CGColorCreateCopyWithAlpha(appearance.progressTintColor.CGColor, 0.2)!
            
            let allRect = rect
            
            let circleRect = CGRectMake(allRect.origin.x + 2, allRect.origin.y + 2, allRect.size.width - 4, allRect.size.height - 4)
            
            let x:CGFloat = allRect.origin.x + (allRect.size.width / 2)
            
            let y:CGFloat = allRect.origin.y + (allRect.size.height / 2)
            
            let angle = CGFloat(progress * 360.0)
            
            // 2
            CGContextSaveGState(context)
            CGContextSetStrokeColorWithColor(context, colorProgressAlpha)
            CGContextSetFillColorWithColor(context, colorBackAlpha)
            CGContextSetLineWidth(context, 2.0)
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
            
            CGContextSetRGBFillColor(context, 1.0, 0.0, 1.0, 1.0)
            CGContextMoveToPoint(context, x, y)
            CGContextAddArc(context, x, y, (allRect.size.width + 4) / 2, -CGFloat(M_PI) / 2, (angle * CGFloat(M_PI)) / 180.0 - CGFloat(M_PI) / 2, 0)
            CGContextClip(context)
            
            CGContextSetStrokeColorWithColor(context, appearance.progressTintColor.CGColor)
            CGContextSetFillColorWithColor(context, appearance.backgroundTintColor.CGColor)
            CGContextSetLineWidth(context, 2.0)
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
            CGContextRestoreGState(context)
            
            // 3
            if appearance.showPercentage {
                
                drawTextInContext(context)
            }
            
        }else{
            
            let circleRect = CGRectInset(allRect, 2.0, 2.0)
            let colorBackAlpha:CGColorRef = CGColorCreateCopyWithAlpha(appearance.backgroundTintColor.CGColor, 0.1)!
            
            appearance.progressTintColor.setStroke()
            CGContextSetFillColorWithColor(context, colorBackAlpha)
        
            CGContextSetLineWidth(context, 2.0)
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
            
            let center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2)
            let radius = (allRect.size.width - 4) / 2 - 3
            let startAngle = -(CGFloat(M_PI) / 2)
            let endAngle = (CGFloat(progress) * 2 * CGFloat(M_PI)) + startAngle
            appearance.progressTintColor.setFill()
            CGContextMoveToPoint(context, center.x, center.y);
            CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
            CGContextClosePath(context);
            CGContextFillPath(context);
        }
        
    }
    
    // 画进度
    
    func drawTextInContext(context:CGContextRef) {
        
        let appearance:DZMProgressAppearance = progressAppearance
        
        let allRect:CGRect = bounds
        
        let font = appearance.percentageTextFont
        
        let text = "\(progress * 100)%"
        
        let textSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: [.UsesLineFragmentOrigin,.UsesFontLeading], attributes: [NSFontAttributeName:font], context: nil).size
        
        let x:CGFloat = CGFloat(floorf(Float(allRect.size.width) / 2)) + 3 + appearance.percentageTextOffset.x
        let y:CGFloat = CGFloat(floorf(Float(allRect.size.width) / 2)) - 6 + appearance.percentageTextOffset.y
        
        (text as NSString).drawAtPoint(CGPointMake(x - textSize.width / 2, y), withAttributes: [NSFontAttributeName:font,NSForegroundColorAttributeName:appearance.percentageTextColor])
    }
}
