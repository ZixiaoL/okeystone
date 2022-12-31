//
//  QRScanViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import AVKit

protocol ScanViewControllerDelegate {
    func handleQRScanResult(result: String);
}

class ScanViewController: UIViewController {
    
    var delegate: ScanViewControllerDelegate?
    
    var captureDevice: AVCaptureDevice?
    var captureInput: AVCaptureDeviceInput?
    var mataOutput: AVCaptureMetadataOutput?
    var captureSession: AVCaptureSession?
    var capturePreView: AVCaptureVideoPreviewLayer?

    var torchTag = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let scanView = self.view as? ScanView {
            scanView.torchBtn.addTarget(self, action: #selector(torchAction(btn:)), for: UIControl.Event.touchUpInside)
            scanView.albumBtn.addTarget(self, action: #selector(albumAction(btn:)), for: UIControl.Event.touchUpInside)
        }
        setupCaptureSession()
        startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if torchTag {
            try? captureDevice?.lockForConfiguration()
            captureDevice?.torchMode = .off
            captureDevice?.unlockForConfiguration()
            torchTag = false
        }
    }
    
    // MARK: - 开始扫描
    func startScan() {
        if ((captureSession?.isRunning)!) {
            return
        }
        captureSession?.startRunning()
    }
    
    // MARK: - 停止扫描
    func endScan() {
        if (!(captureSession?.isRunning)!) {
            return
        }
        captureSession?.stopRunning()
    }
    
    func setupCaptureSession() {
        if(captureSession != nil) {
            return
        }
        captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            try captureInput = AVCaptureDeviceInput.init(device: captureDevice!)
        } catch {
            
        }
        
        mataOutput = AVCaptureMetadataOutput.init()
        mataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        captureSession = AVCaptureSession.init()
        
        if ((captureSession?.canAddInput(captureInput!))!) {
            captureSession?.addInput(captureInput!)
        }
        
        if ((captureSession?.canAddOutput(mataOutput!))!) {
            captureSession?.addOutput(mataOutput!)
        }
        
        if ((captureSession?.canSetSessionPreset(AVCaptureSession.Preset.high))!) {
            captureSession?.sessionPreset = .high
        }
        
        mataOutput?.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        capturePreView = AVCaptureVideoPreviewLayer.init(session: captureSession!)
        capturePreView?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        capturePreView?.frame = self.view.frame
        self.view.layer.insertSublayer(capturePreView!, at: 0)
        
        captureSession?.startRunning()
        
        let scanView = self.view as! ScanView
        
        let rect = capturePreView!.metadataOutputRectConverted(fromLayerRect: scanView.interestRect)
        
        mataOutput?.rectOfInterest = rect
        
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
// 扫描到数据后调用
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if (metadataObjects.count == 0) {
            return
        }
        
        // 开启系统震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        // 停止扫描
        endScan()
        
        // 返回数据
        let object = metadataObjects.first as! AVMetadataMachineReadableCodeObject
        let result = object.stringValue
        if self.delegate != nil {
            self.delegate?.handleQRScanResult(result: result!)
        }
    }
}

// MARK: - UINavigationControllerDelegate UIImagePickerControllerDelegate
// 相册获取的照片进行处理
extension ScanViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            // 取出选中的图片
            let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            // 创建一个探测器
            let decteor = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            // 利用探测器探测数据
            let ciimg = CIImage.init(cgImage: img.cgImage!)
            let fetures = decteor?.features(in: ciimg)
            if (fetures?.count)! > 0 {
                if let qrFeture = fetures?.first as? CIQRCodeFeature {
                    // 停止扫描
                    self.endScan()
                    // 返回二维码信息
                    if (self.delegate != nil) {
                        self.delegate?.handleQRScanResult(result: qrFeture.messageString!)
                    }
                }
            } else {
                print("没有检测到二维码")
            }
        }
        
    }
    
    @objc func torchAction(btn: UIButton) {
        if let scanView = self.view as? ScanView, (captureDevice?.hasTorch)! {
            if (!torchTag) {
                try? captureDevice?.lockForConfiguration()
                try? captureDevice?.setTorchModeOn(level: 0.6)
                captureDevice?.unlockForConfiguration()
                torchTag = true
                    scanView.torchImgView.image = UIImage(named: "scan_torch_on")
                scanView.torchTitleLab.text = NSLocalizedString("button_title_torchon", comment: "")
            } else {
                try? captureDevice?.lockForConfiguration()
                captureDevice?.torchMode = .off
                captureDevice?.unlockForConfiguration()
                torchTag = false
                scanView.torchImgView.image = UIImage(named: "scan_torch_off")
                scanView.torchTitleLab.text = NSLocalizedString("button_title_torchoff", comment: "")
            }
        }
    }

    @objc func albumAction(btn: UIButton) {
        let imageController = UIImagePickerController.init()
        imageController.sourceType = .photoLibrary
        imageController.delegate = self
        self.present(imageController, animated: true, completion: nil)
    }
    
}


