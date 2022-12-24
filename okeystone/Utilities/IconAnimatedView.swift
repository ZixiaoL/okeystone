//
//  IconAnimatedView.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/17.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

@IBDesignable
class IconAnimatedView: UIView, CAAnimationDelegate {
    
    let colorOne = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    let colorTwo = #colorLiteral(red: 0.5, green: 0.3668999731, blue: 0.1045443202, alpha: 1).cgColor
    let colorThree = #colorLiteral(red: 1, green: 0.7337999463, blue: 0.2090886404, alpha: 1).cgColor
    
    let icon = CAShapeLayer()
    let gradient = CAGradientLayer()
    
    var currentGradient: Int = 0
    var gradientSet = [[CGColor]]()
    
    @objc private func handleEnterForeground() {
        animateGradient()
    }
    
    func animateGradient() {
        // cycle through all the colors, feel free to add more to the set
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        // animate over 3 seconds
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 3.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        //gradientChangeAnimation.repeatCount = Float.infinity
        gradientChangeAnimation.delegate = self
        gradient.add(gradientChangeAnimation, forKey: "gradientChangeAnimation")
    }
    
    func createGradientView() {
        
        // draw icon
        icon.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 50, dy: 50)).cgPath
        icon.strokeColor = UIColor.gray.cgColor
        icon.fillColor = UIColor.clear.cgColor
        icon.lineWidth = 5.0
        
        
        // overlap the colors and make it 3 sets of colors
        gradientSet.append([colorOne, colorTwo])
        gradientSet.append([colorTwo, colorThree])
        gradientSet.append([colorThree, colorOne])
        
        // set the gradient size to be the entire screen
        gradient.frame = self.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        gradient.mask = icon
        
        self.layer.insertSublayer(gradient, at: 0)
        
        animateGradient()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        // if our gradient animation ended animating, restart the animation by changing the color set
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        createGradientView()
        animateGradient()
    }
    
}
