//
//  Bubble.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 20/4/23.
//

import Foundation
import UIKit

class Bubble: UIButton {
    // Class Bubble inherits from UIButton used during game

    var xPosition = 0
    var yPosition = 0
    var maxYPosition = 0
    var diametre = 50

    var probAppearance = 0.5
    var score = 1

    var colorCode = 0 //to compare same colored bubbles easily

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPosition(xPosition: Int, yPosition: Int, maxYPosition: Int) {
        //sets x and y postion of the frame
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.maxYPosition = maxYPosition
        self.frame = CGRect(x: xPosition, y: yPosition, width: diametre,
            height: diametre)
        self.layer.cornerRadius = 0.5 * self.bounds.size.width //make the botton round
    }

    func animation () {
        //bubble appearing animation
        let springAnimation = CASpringAnimation (keyPath: "transform.scale")
        springAnimation.duration = 0.6
        springAnimation.fromValue = 1
        springAnimation.toValue = 0.8
        springAnimation.repeatCount = 1
        springAnimation.initialVelocity = 0.5
        springAnimation.damping = 1
        layer.add(springAnimation, forKey: nil)
    }

    func flash () {
        //bubble disappearinig animation
        let flash = CABasicAnimation (keyPath: "opacity")
        flash.duration = 1
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.repeatCount = 3
        flash.autoreverses = true
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer.add(flash, forKey: nil)
    }
}

//For each type of bubble, there is a subclass. It was designed this way so that in the future
//different bubbles can have different properties (such as diametre) and behaviors (such as appearing animations)

class RedBubble: Bubble {
    override init(frame: CGRect) {
        super.init(frame: frame)
        score = 1
        colorCode = 1
        self.backgroundColor = .red

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PinkBubble: Bubble {
    override init(frame: CGRect) {
        super.init(frame: frame)
        score = 2
        colorCode = 2
        self.backgroundColor = UIColor(red: 0.98, green: 0.75, blue: 0.9, alpha: 1)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GreenBubble: Bubble {
    override init(frame: CGRect) {
        super.init(frame: frame)
        score = 5
        colorCode = 3
        self.backgroundColor = .green
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BlueBubble: Bubble {
    override init(frame: CGRect) {
        super.init(frame: frame)
        score = 8
        colorCode = 4
        self.backgroundColor = .blue
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BlackBubble: Bubble {
    override init(frame: CGRect) {
        super.init(frame: frame)
        score = 10
        colorCode = 5
        self.backgroundColor = .black
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
