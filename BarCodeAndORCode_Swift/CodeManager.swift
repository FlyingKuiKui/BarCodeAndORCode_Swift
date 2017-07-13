//
//  CodeManager.swift
//  BarCodeAndORCode_Swift
//
//  Created by 王盛魁 on 2017/7/6.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

import UIKit

class CodeManager: NSObject {
    // 二维码
    class func generateQRCode(messgae:NSString,width:CGFloat,height:CGFloat) -> UIImage {
        var returnImage:UIImage?
        if (messgae.length > 0 && width > 0 && height > 0){
            let inputData = messgae.data(using: String.Encoding.utf8.rawValue)! as NSData
            // CIQRCodeGenerator
            let filter = CIFilter.init(name: "CIQRCodeGenerator")!
            filter.setValue(inputData, forKey: "inputMessage")
            var ciImage = filter.outputImage!
            let min = width > height ? height :width;
            let scaleX = min/ciImage.extent.size.width
            let scaleY = min/ciImage.extent.size.height
            ciImage = ciImage.applying(CGAffineTransform.init(scaleX: scaleX, y: scaleY))
            returnImage = UIImage.init(ciImage: ciImage)
        }else {
            returnImage = nil;
        }
        return returnImage!
    }
    class func generateQRCodeWithCenterImage(messgae:NSString,width:CGFloat,height:CGFloat,centerImage:UIImage) -> UIImage {
        let backImage = generateQRCode(messgae: messgae, width: width, height: height)
        UIGraphicsBeginImageContext(backImage.size);
        backImage.draw(in: CGRect.init(x: 0, y: 0, width: backImage.size.width, height: backImage.size.height))
        let centerImageWH:CGFloat = backImage.size.width > backImage.size.height ? backImage.size.height * 0.2 : backImage.size.width*0.2
        centerImage.draw(in: CGRect.init(x: (backImage.size.width - centerImageWH)*0.5, y: (backImage.size.height - centerImageWH)*0.5, width: centerImageWH, height: centerImageWH))
        let returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return returnImage!
    }
    class func decodeQRCode(QRCodeImage:UIImage) -> NSString {
        var outputString:NSString?
        let detector:CIDetector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let image = CIImage.init(image: QRCodeImage)!
        let features = detector.features(in: image) as NSArray
        for feature in features {
            outputString = (feature as! CIQRCodeFeature).messageString! as NSString;
        }
        return outputString!
    }
    
    
    
    // 条形码
    class func generateBarCode(messgae:NSString,width:CGFloat,height:CGFloat) -> UIImage {
        var returnImage:UIImage?
        if (messgae.length > 0 && width > 0 && height > 0){
            let inputData:NSData? = messgae.data(using: String.Encoding.utf8.rawValue)! as NSData
            // CICode128BarcodeGenerator
            let filter = CIFilter.init(name: "CICode128BarcodeGenerator")!
            filter.setValue(inputData, forKey: "inputMessage")
            var ciImage = filter.outputImage!
            let scaleX = width/ciImage.extent.size.width
            let scaleY = height/ciImage.extent.size.height
            ciImage = ciImage.applying(CGAffineTransform.init(scaleX: scaleX, y: scaleY))
            returnImage = UIImage.init(ciImage: ciImage)
        }else {
            returnImage = nil;
        }
        return returnImage!
    }
}














