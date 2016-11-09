//
//  ViewController.swift
//  DZMProgressView
//
//  Created by 邓泽淼 on 16/7/27.
//  Copyright © 2016年 DZM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        /*
         DZMProgressView: OC Swift 版都有
         自带 KVO 监听各个属性变化 -> 字体 颜色 背景颜色 圆圈颜色 等
         DZMProgressAppearance 可使用单利全局控制
         单利方法: DZMProgressAppearance.progressAppearance
         
         也可按 1 3 一样单独创建 单个控制 
         也可按 2 不创建 默认自带
         */
        
        
        // 1
        let progressAppearance1 = DZMProgressAppearance()
        progressAppearance1.type = .annular
        progressAppearance1.progressTintColor = UIColor.red
        
        let progressView1:DZMProgressView = DZMProgressView()
        progressView1.frame = CGRect(x: 100, y: 80, width: 100, height: 100)
        progressView1.progress = 0.5
        progressView1.progressAppearance = progressAppearance1
        view.addSubview(progressView1)
        
        // 2
        let progressView2:DZMProgressView = DZMProgressView()
        progressView2.frame = CGRect(x: 100, y: 240, width: 100, height: 100)
        progressView2.progress = 0.7
        view.addSubview(progressView2)
        
        // 3
        let progressAppearance3 = DZMProgressAppearance()
        progressAppearance3.type = .pie
        
        let progressView3:DZMProgressView = DZMProgressView()
        progressView3.frame = CGRect(x: 100, y: 400, width: 100, height: 100)
        progressView3.progress = 0.4
        progressView3.progressAppearance = progressAppearance3
        view.addSubview(progressView3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

