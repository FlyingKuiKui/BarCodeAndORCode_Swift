//
//  CodeDiscernViewController.swift
//  BarCodeAndORCode_Swift
//
//  Created by 王盛魁 on 2017/7/7.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
class CodeDiscernViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var dataArray:NSArray?
    var scanRect:CGRect?
    var isQRCodeCaptured:Bool?
    var txtLbl:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataArray?[0] ?? "测试传值")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "相册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(openSystemPhoto))
        
        checkCamera()
        
        // Do any additional setup after loading the view.
    }
    private func checkCamera() -> Void {
        isQRCodeCaptured = false
        scanRect = CGRect.init(x: 60.0, y: 164.0, width: self.view.bounds.size.width-120.0, height: self.view.bounds.size.width-120.0)

        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (genter) in
                if (genter){
                    self.openCamera()
                }else{
                    print(">>>访问受限")
                }
            }
            break
        case .authorized:
            self.openCamera()
            break
        case .restricted:
            print(">>>访问受限")
            break
        case .denied:
            print(">>>访问受限")
            break
        }
    }
    private func openCamera() -> Void {
        let session = AVCaptureSession.init()
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let deviceInput = try? AVCaptureDeviceInput(device:device)
        if (deviceInput != nil){
            session.addInput(deviceInput)
            let metadataOutput = AVCaptureMetadataOutput.init()
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            session.addOutput(metadataOutput) //  这行代码要在设置 metadataObjectTypes 前
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code] // 识别图片类型
            let previewLayer = AVCaptureVideoPreviewLayer.init(session: session)!
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.frame = self.view.frame
            self.view.layer.insertSublayer(previewLayer, at:0)
            weak var weakSelf = self
            NotificationCenter.default.addObserver(forName: AVCaptureInputPort.init().formatDescription as? NSNotification.Name, object: self, queue: OperationQueue.current, using: { (note) in
                metadataOutput.rectOfInterest = previewLayer.metadataOutputRectOfInterest(for: (weakSelf?.scanRect)!)
                // 如果不设置，整个屏幕都可以扫
            })
            let scanView = QRScanView.init(frame: scanRect!)
            self.view.addSubview(scanView)
            session.startRunning()
            
            txtLbl = UILabel.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 30))
            txtLbl?.textAlignment = NSTextAlignment.left
            txtLbl?.textColor = UIColor.red
            self.view.addSubview(txtLbl!)
            
            let torchBtn = UIButton.init()
            torchBtn.frame = CGRect.init(x: 0, y: 0, width: 100, height: 30)
            torchBtn.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: (scanRect?.size.height)!+300)
            torchBtn.setTitle("闪光灯", for: UIControlState.normal)
            torchBtn.setTitleColor(UIColor.red, for: UIControlState.normal)
            torchBtn.addTarget(self, action: #selector(openOrCloseTorchlight), for: UIControlEvents.touchUpInside)
            self.view.addSubview(torchBtn)
            
        }else{
            print(">>启用失败")
        }
    }
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if (isQRCodeCaptured == false && metadataObjects.count > 0){
            isQRCodeCaptured = true
            let metadataObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            var decodeMessage = ""
            switch metadataObject.type {
            case AVMetadataObjectTypeCode128Code:
                // 条形码
                decodeMessage = metadataObject.stringValue
                break
            case AVMetadataObjectTypeQRCode:
                // 二维码
                decodeMessage = metadataObject.stringValue
                break
            case AVMetadataObjectTypeEAN13Code:
                // ISBN书号条码、EAN13码
                decodeMessage = metadataObject.stringValue
                break
            default:
                break
            }
            print(decodeMessage)
            txtLbl?.text = decodeMessage
        }
    }
    
    // MARK:识别手机相册内二维码图片
    @objc private func openSystemPhoto() -> Void {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        imagePickerController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        imagePickerController.allowsEditing = true
        // 相册
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        // 时刻
//        imagePickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        // 相机
//        imagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String];
//        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera

        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let sourceType = picker.sourceType
        switch sourceType {
        case UIImagePickerControllerSourceType.photoLibrary:
            print(">>数据来源于相册<<")
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            let imageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            let cropRect = info[UIImagePickerControllerCropRect] as! CGRect
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedString = CodeManager.decodeQRCode(QRCodeImage:editedImage)
            let originalString = CodeManager.decodeQRCode(QRCodeImage:originalImage)
            print("mediaType：",mediaType,"\nimageUrl：",imageUrl,"\ncropRect：",cropRect,"\neditedString：",editedString,"\noriginalString：",originalString)
            txtLbl?.text = originalString as String
            break
        case UIImagePickerControllerSourceType.savedPhotosAlbum:
            print(">>数据来源于时刻<<")
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            let imageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
            let cropRect = info[UIImagePickerControllerCropRect] as! CGRect
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedString = CodeManager.decodeQRCode(QRCodeImage:editedImage)
            let originalString = CodeManager.decodeQRCode(QRCodeImage:originalImage)
            print("mediaType：",mediaType,"\nimageUrl：",imageUrl,"\ncropRect：",cropRect,"\neditedString：",editedString,"\noriginalString：",originalString)
            txtLbl?.text = originalString as String

            break
        case UIImagePickerControllerSourceType.camera:
            print(">>数据来源于相机<<")
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            let cropRect = info[UIImagePickerControllerCropRect] as! CGRect
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let mediaMetadata = info[UIImagePickerControllerMediaMetadata] as! NSDictionary
            let editedString = CodeManager.decodeQRCode(QRCodeImage:editedImage)
            let originalString = CodeManager.decodeQRCode(QRCodeImage:originalImage)
            print("mediaMetadata:%@",mediaMetadata)
//            if mediaType.isEqual(to: kUTTypeImage as String){
//                print("图片")
//            }else{
//                print("视频")
//            }
            print("mediaType：",mediaType,"\ncropRect：",cropRect,"\neditedString：",editedString,"\noriginalString：",originalString)
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    // 打开或者关闭闪光灯
    @objc private func openOrCloseTorchlight(){
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)!
        if device.hasTorch == true{
            let deviceLock:Bool = ((try? device.lockForConfiguration()) != nil)
            if deviceLock == true {
                if device.torchMode == AVCaptureTorchMode.off {
                    device.torchMode = AVCaptureTorchMode.on
                }else{
                    device.torchMode = AVCaptureTorchMode.off
                }
                device.unlockForConfiguration()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
