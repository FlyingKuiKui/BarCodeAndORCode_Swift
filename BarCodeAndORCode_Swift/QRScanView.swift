//
//  QRScanView.swift
//  BarCodeAndORCode_Swift
//
//  Created by 王盛魁 on 2017/7/10.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

import UIKit

class QRScanView: UIView {
    private var scanRect:CGRect?
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.clear
        scanRect = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let context = UIGraphicsGetCurrentContext();
        UIColor.black.withAlphaComponent(0.5).setFill()
        
        let screenPath = CGMutablePath()
        screenPath.addRect(self.bounds)
        
        let scanPath = CGMutablePath()
        scanPath.addRect(scanRect!)
        
        let path = CGMutablePath()
        path.addPath(screenPath)
        path.addPath(scanPath)
        
        context?.addPath(path)
        context?.drawPath(using:CGPathDrawingMode.eoFill)
        
        
        /*
         
        CGPathRelease(screenPath);
        CGPathRelease(scanPath);
        CGPathRelease(path);
 */
    }

}
