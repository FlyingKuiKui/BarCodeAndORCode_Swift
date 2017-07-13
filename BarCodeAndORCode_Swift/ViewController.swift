//
//  ViewController.swift
//  BarCodeAndORCode_Swift
//
//  Created by 王盛魁 on 2017/7/6.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let goToNext = UIButton.init(frame: CGRect.init(x: 10, y: 70, width: 300, height: 40))
        goToNext.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: 90)
        goToNext.setTitle("识别二维码/条形码", for: UIControlState.normal)
        goToNext.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        goToNext.setTitleColor(UIColor.white, for: UIControlState.normal)
        goToNext.backgroundColor = UIColor.gray
        goToNext.addTarget(self, action: #selector(ViewController.goToNextAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(goToNext)
        
        creatQRCode()
        creatBarCode()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func goToNextAction() -> Void{
        let CodeDiscernVC = CodeDiscernViewController()
        CodeDiscernVC.dataArray = ["传值1","传值11"]
        self.navigationController?.pushViewController(CodeDiscernVC, animated: false)
        
    }
    
    
    // 测试二维码的生成
    func creatQRCode() -> Void{
        let QRCodeImageView = UIImageView.init()
//        let QRCodeImage = CodeManager.generateQRCode(messgae:"ajdvbcajhbdclahbdlhcvab dhjvcakhdc ahd ckahdc bkahdc ahdvkhadvhdhadbcjhabdjchadbjchbadhkjbc",width:300.0,height:300.0)
        let QRCodeImage = CodeManager.generateQRCodeWithCenterImage(messgae: "大家好！SALM系统必须使用谷歌浏览器，下载请访问谷歌浏览器下载。SALM使用手册请访问SALM操作说明。用户申请时，请填写“合法邮箱地址”，“全名”请填写中文姓名，", width: 300.0, height: 300.0, centerImage: UIImage.init(named: "centerImage")!)
        QRCodeImageView.frame = CGRect.init(x: 0, y: 140, width: 200, height: 200)
        QRCodeImageView.image = QRCodeImage
        QRCodeImageView.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: 240)
        self.view.addSubview(QRCodeImageView)
    }
    // 测试条形码的生成
    func creatBarCode() -> Void {
        let BarCodeImageView = UIImageView.init()
        let BarCodeImage = CodeManager.generateBarCode(messgae:"234176349173476517346",width:300.0,height:100.0)
        BarCodeImageView.frame = CGRect.init(x: 0, y: 380, width: 300, height: 100)
        BarCodeImageView.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: 430)
        BarCodeImageView.image = BarCodeImage
        self.view.addSubview(BarCodeImageView)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

