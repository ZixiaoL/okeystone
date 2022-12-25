//
//  BackgroundView.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/17.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

@IBDesignable
class BackgroundView: UIView, CAAnimationDelegate {
    
    let colorTwo = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
    let gradient = CAGradientLayer()
    var gradientSet = [CGColor]()
    
    func createGradientView() {
        let colorOne = self.backgroundColor?.cgColor
        // overlap the colors and make it 2 sets of colors
        gradientSet = [colorOne!, colorTwo]
        
        // set the gradient size to be the entire screen
        gradient.frame = self.bounds
        gradient.colors = gradientSet
        gradient.startPoint = CGPoint(x:0.5, y:0)
        gradient.endPoint = CGPoint(x:0.5, y:1)
        gradient.drawsAsynchronously = true
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    
    override func draw(_ rect: CGRect) {
        createGradientView()
    }
    
}
