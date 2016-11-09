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
    case annular
    case circle
    case pie
}

import UIKit

/// 该对象可使用单利全局控制 也可以单独创建使用
class DZMProgressAppearance: NSObject {
    
    // 样式
    var type:SMProgressType! = .circle
    
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
    var percentageTextFont:UIFont = UIFont.systemFont(ofSize: 10)
    
    // 进度文字偏移
    var percentageTextOffset:CGPoint = CGPoint.zero
    
    //  初始化
    override init() {
        super.init()
        schemeColor = UIColor.white
        setupColor()
    }
    
    // 设置颜色
    func setupColor() {
        
        progressTintColor = UIColor(cgColor:schemeColor.cgColor.copy(alpha: 1)!)
        backgroundTintColor = UIColor(cgColor:schemeColor.cgColor.copy(alpha: 0.1)!)
        percentageTextColor = UIColor(cgColor:schemeColor.cgColor.copy(alpha: 1)!)
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
    var progress:Float = 0 {
        didSet{
            
            setNeedsDisplay()
        }
    }
    
    /// 配置
    var progressAppearance:DZMProgressAppearance = DZMProgressAppearance.progressAppearance {
        didSet{
            
            setNeedsDisplay()
        }
    }
    
    // 初始化
    convenience init(){
        self.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isOpaque = false
//        registerForKVO()
    }
    
    deinit {
        
//        unregisterFromKVO()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -- KVO
    
    func registerForKVO() {
        
        for keyPath in observableKeypaths() {
            
            addObserver(self, forKeyPath: keyPath, options: NSKeyValueObservingOptions.new, context: nil)
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        setNeedsDisplay()
    }
    
    // MARK: -- Drawing
    
    override func draw(_ rect: CGRect) {
        
        let allRect:CGRect = bounds
        
        let context = UIGraphicsGetCurrentContext()!
        
        let appearance:DZMProgressAppearance = progressAppearance
        
        if appearance.type == .annular {
           
            // 1
            let lineWidth:CGFloat = 1
            
            let processBackgroundPath:UIBezierPath = UIBezierPath()
            
            processBackgroundPath.lineWidth = lineWidth
            
            processBackgroundPath.lineCapStyle = .round
            
            let center:CGPoint = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
            
            let radius:CGFloat = (bounds.size.width - lineWidth)/2
            
            let startAngle:CGFloat = -(CGFloat(M_PI) / 2)
            
            var endAngle = (2 * CGFloat(M_PI) + startAngle)
            
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
           
            appearance.backgroundTintColor.set()
           
            processBackgroundPath.stroke()
            
            // 2
            let processPath:UIBezierPath = UIBezierPath()
            
            processPath.lineCapStyle = .round
            
            processPath.lineWidth = lineWidth
            
            endAngle = (CGFloat(progress) * 2 * CGFloat(M_PI)) + startAngle
            
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            appearance.progressTintColor.set()
            
            processPath.stroke()
            
            // 3
            if appearance.showPercentage {
                
                drawTextInContext(context)
            }
            
        }else if appearance.type == .circle {
            
            // 1
            let colorBackAlpha:CGColor = appearance.backgroundTintColor.cgColor.copy(alpha: 0.05)!
            
            let colorProgressAlpha:CGColor = appearance.progressTintColor.cgColor.copy(alpha: 0.2)!
            
            let allRect = rect
            
            let circleRect = CGRect(x: allRect.origin.x + 2, y: allRect.origin.y + 2, width: allRect.size.width - 4, height: allRect.size.height - 4)
            
            let x:CGFloat = allRect.origin.x + (allRect.size.width / 2)
            
            let y:CGFloat = allRect.origin.y + (allRect.size.height / 2)
            
            let angle = CGFloat(progress * 360.0)
            
            // 2
            context.saveGState()
            context.setStrokeColor(colorProgressAlpha)
            context.setFillColor(colorBackAlpha)
            context.setLineWidth(2.0)
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
            
            context.setFillColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
            context.move(to: CGPoint(x: x, y: y))
            context.addArc(center: CGPoint(x:x,y:y), radius: (allRect.size.width + 4) / 2, startAngle: -CGFloat(M_PI) / 2, endAngle: (angle * CGFloat(M_PI)) / 180.0 - CGFloat(M_PI) / 2, clockwise: false)
            context.clip()
            
            context.setStrokeColor(appearance.progressTintColor.cgColor)
            context.setFillColor(appearance.backgroundTintColor.cgColor)
            context.setLineWidth(2.0)
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
            context.restoreGState()
            
            // 3
            if appearance.showPercentage {
                
                drawTextInContext(context)
            }
            
        }else{
            
            let circleRect = allRect.insetBy(dx: 2.0, dy: 2.0)
            let colorBackAlpha:CGColor = appearance.backgroundTintColor.cgColor.copy(alpha: 0.1)!
            
            appearance.progressTintColor.setStroke()
            context.setFillColor(colorBackAlpha)
        
            context.setLineWidth(2.0)
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
            
            let center = CGPoint(x: allRect.size.width / 2, y: allRect.size.height / 2)
            let radius = (allRect.size.width - 4) / 2 - 3
            let startAngle = -(CGFloat(M_PI) / 2)
            let endAngle = (CGFloat(progress) * 2 * CGFloat(M_PI)) + startAngle
            appearance.progressTintColor.setFill()
            context.move(to: CGPoint(x: center.x, y: center.y));
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath();
            context.fillPath();
        }
        
    }
    
    // 画进度
    
    func drawTextInContext(_ context:CGContext) {
        
        let appearance:DZMProgressAppearance = progressAppearance
        
        let allRect:CGRect = bounds
        
        let font = appearance.percentageTextFont
        
        let text = "\(String(format: "%.0f",fabsf(progress) * 100))%"
        
        let textSize = (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSFontAttributeName:font], context: nil).size
        
        let x:CGFloat = CGFloat(floorf(Float(allRect.size.width) / 2)) + 3 + appearance.percentageTextOffset.x
        let y:CGFloat = CGFloat(floorf(Float(allRect.size.width) / 2)) - 6 + appearance.percentageTextOffset.y
        
        (text as NSString).draw(at: CGPoint(x: x - textSize.width / 2, y: y), withAttributes: [NSFontAttributeName:font,NSForegroundColorAttributeName:appearance.percentageTextColor])
    }
}
