//
//  FloatingBallBehavior.swift
//  okeystone
//
//  Created by Zixiao Li on 12/23/22.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

class FloatingBallBehavior: UIDynamicBehavior
{
    
    var attachmentBehavior: UIAttachmentBehavior?
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 0
        behavior.resistance = 0.5
        return behavior
    }()
    
    
    func push(_ item: UIDynamicItem, _ pushDirection: CGVector) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.pushDirection = pushDirection
        push.magnitude = 3
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    var gravityBehavior: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
        return behavior
    }()
    
    
    func addItem(_ item: UIDynamicItem) {
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: center)
            attachmentBehavior?.length = 120
            addChildBehavior(attachmentBehavior!)
        }
        itemBehavior.addItem(item)
        gravityBehavior.addItem(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        if (attachmentBehavior != nil) {
            removeChildBehavior(attachmentBehavior!)
        }
        itemBehavior.removeItem(item)
        gravityBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(itemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
