//
//  QRScanView.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import AVKit

@IBDesignable
class ScanView: UIView {
    
    var centerView: UIImageView?
    var torchBtn: UIButton!
    var torchImgView: UIImageView!
    var torchTitleLab: UILabel!
    var albumBtn: UIButton!
    
    
    var torchTag = false
    
    lazy var interestRect: CGRect = {
        let screenWidth = self.frame.width
        let screenHeight = self.frame.height
        let leftPadding: CGFloat = 60.0
        let topPadding: CGFloat = 60.0
        let rectLength = screenWidth - leftPadding * 2
        let rect = CGRect.init(x: leftPadding,
                               y: (screenHeight - rectLength) / 2 - topPadding,
                               width: rectLength,
                               height: rectLength)
        return rect
    }()
    
    func setupScanLine() {
        centerView = UIImageView.init(frame: CGRect(x: self.interestRect.origin.x+1,
                                                  y: self.interestRect.origin.y+1,
                                                  width: self.interestRect.size.width-2,
                                                  height: 3))
        //scanView!.backgroundColor = UIColor.white
        centerView?.image = UIImage(named: "scan_line")
        let animation = CABasicAnimation.init(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = interestRect.size.height
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = 3
        animation.isRemovedOnCompletion = false
        animation.repeatCount = MAXFLOAT
        centerView?.layer.add(animation, forKey: "y_transaltion")
        self.addSubview(centerView!)
        
    }
    
    func setupInterestRectBoard() {
        let interestBoardLayer = CAShapeLayer.init()
        
        let rect = CGRect.init(x: self.interestRect.origin.x+0.5,
                               y: self.interestRect.origin.y+0.5,
                               width: self.interestRect.size.width-1,
                               height: self.interestRect.size.height-1)
        let path = UIBezierPath.init(rect: rect)
        interestBoardLayer.path = path.cgPath
        interestBoardLayer.strokeColor = UIColor.white.cgColor
        interestBoardLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(interestBoardLayer)
    }
    
    func setupCoverView() {
        let coverLayer = CALayer.init()
        coverLayer.frame = self.frame
        coverLayer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.35).cgColor
        //coverLayer.backgroundColor = UIColor.red.cgColor
        
        let maskLayer = CAShapeLayer.init()
        let path = UIBezierPath.init(rect: self.frame)
        let path1 = UIBezierPath.init(rect: self.interestRect).reversing()
        path.append(path1)
        maskLayer.path = path.cgPath
        
        coverLayer.mask = maskLayer
        
        self.layer.addSublayer(coverLayer)
    }
    
    func setupTopView() {
        let width: CGFloat = self.frame.width
        let height: CGFloat = 100
        let x: CGFloat = 0
        let y: CGFloat = 0
        
        let topView = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
        topView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        topView.alpha = 0.2
        self.addSubview(topView)
    }
    
    func setupBottomView() {
        let width: CGFloat = self.frame.width
        let height: CGFloat = 100
        let x: CGFloat = 0
        let y: CGFloat = self.frame.height - height
        
        let bottomView = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
        bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        bottomView.alpha = 0.2
        self.addSubview(bottomView)
    }
    
    func setupButtonView() {
        let width: CGFloat = self.frame.width
        let height: CGFloat = 100
        
        var x: CGFloat = width / 4
        let y: CGFloat = self.frame.height - height / 2
        
        let torchView = makeButtonView(tag: 1,
                                       title: NSLocalizedString("button_title_torch_off", comment: ""),
                                       imageName: "scan_torch_off")
        torchView.center = CGPoint(x: x, y: y)
        self.addSubview(torchView)
        
        x = width * 3 / 4
        let albumView = makeButtonView(tag: 2,
                                       title: NSLocalizedString("button_title_album", comment: ""),
                                       imageName: "scan_album")
        albumView.center = CGPoint(x: x, y: y)
        self.addSubview(albumView)
    }
    
    func makeButtonView(tag: Int, title: String, imageName: String) -> UIView {
        let iconLength: CGFloat = 30
        let labHeight: CGFloat = 20
        let safeMiddle: CGFloat = 4
        let safeBoth: CGFloat = 4
        let btnLength: CGFloat = 62
        
        let view = UIView.init(frame: CGRect.init(x: 0,
                                                  y: 0,
                                                  width: btnLength,
                                                  height: btnLength))
        
        let imageView = UIImageView.init(image: UIImage.init(named: imageName))
        imageView.frame = CGRect(x: (btnLength - iconLength) / 2,
                                 y: safeBoth,
                                 width: iconLength,
                                 height: iconLength)
        view.addSubview(imageView)
        
        let label = UILabel.init(frame: CGRect(x: 0,
                                               y: safeBoth + iconLength + safeMiddle,
                                               width: btnLength,
                                               height: labHeight))
        label.text = NSLocalizedString(title, comment: "")
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont(name: label.font.fontName, size: 14)
        //titleLab.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        
        let btn = UIButton.init(frame: CGRect.init(x: 0,
                                                   y: 0,
                                                   width: btnLength,
                                                   height: btnLength))
        btn.tag = tag
        //view.backgroundColor = UIColor.red
        view.addSubview(btn)
        switch tag {
        case 1:
            torchBtn = btn
            torchImgView = imageView
            torchTitleLab = label
        case 2:
            albumBtn = btn
        default:
            break
        }
        
        return view
    }
    
    override func draw(_ rect: CGRect) {
        setupCoverView()
        setupInterestRectBoard()
        setupScanLine()
        setupTopView()
        setupBottomView()
        setupButtonView()
    }
    
}
