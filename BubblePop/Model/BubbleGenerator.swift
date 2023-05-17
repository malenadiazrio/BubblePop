//
//  BubbleGenerator.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 21/4/23.
//

import Foundation
import UIKit


enum BubbleError: Error {
    case noSpaceScreen
}
class BubbleGenerator {
    //class that handles the generation of bubbles inside the game
    //the default bubble generator corresponds to teh one used in classic mode

    //game area
    var minX: Int = 0
    var minY: Int = 0
    var maxY: Int = 400
    var maxX: Int = 400

    var bubblesDict = [Int: Bubble]()//bubbles available
    var id = 0 //unique ids of bubbles
    var previousColorCode = 0 //previous bubble type

    var probAppearance: [String: Float] = ["red": 0.4, "pink": 0.3, "green": 0.15, "blue": 0.1, "black": 0.05]
    var probRangeAppearance = [String: ClosedRange<Float>]() //for code visualization purposes

    init() {
        transformProbAppearance() //for code visualization purposes (see getRandomColorBubble function)
    }

    func setLimitsFromFrame(frame: CGRect) {
        //set the limits of the game area given a frame
        minX = Int(frame.minX)
        minY = Int(frame.minY)
        maxX = Int(frame.maxX)
        maxY = Int(frame.maxY)
    }

    func generateBubble() throws -> Bubble {
        var bubble = getRandomColorBubble() // get color
        try assignPosition(bubble: bubble) // assign position
        bubble = assignId(bubble: bubble) // assign id
        bubble.animation() //appear animation
        bubblesDict[bubble.tag] = bubble //add it to dictionnary
        return bubble
    }

    func assignId(bubble: Bubble) -> Bubble {
        bubble.tag = id //assign unique id
        id += 1
        return bubble
    }

    func assignPosition(bubble: Bubble) throws {
        //randomly assigns a position where the bubble does not overlap with any other bubble
        //if it cannot find a position in 500 iterations it returns an error
        var overlap = true
        var iterations = 0
        var xPosition = 0
        var yPosition = 0
        while iterations < 500 && overlap {
            xPosition = Int.random(in: minX...maxX - bubble.diametre)
            yPosition = Int.random(in: minY...maxY - bubble.diametre)
            bubble.setPosition(xPosition: xPosition, yPosition: yPosition, maxYPosition: 0)
            overlap = checkOverlap(bubbleOneFrame: bubble.frame)
            iterations += 1
        }
        guard iterations < 500 else {
            throw BubbleError.noSpaceScreen
        }
    }

    func checkOverlap(bubbleOneFrame: CGRect) -> Bool {
        //for every bubble in the dictionnary check if the bubble overlaps with them
        for (_, bubbleTwo) in bubblesDict {
            if bubbleTwo.frame.intersects(bubbleOneFrame) {
                return true
            }
        }
        return false
    }

    func removeBubble(id: Int) {
        bubblesDict.removeValue(forKey: id)
    }

    func randomBubble() -> Bubble? { //select a random bubble
        return bubblesDict.values.randomElement()
    }

    func getScore(id: Int) -> Int {
        //get the score of a bubble. If the previous bubble removed had the same color, multiply the score by 1.5
        let bubble = bubblesDict[id]!
        var score = Float(bubble.score)
        if previousColorCode == bubble.colorCode //check if previous has same color
        {
            score = score * 1.5
        }
        previousColorCode = bubble.colorCode
        return Int(round(score))
    }

    func transformProbAppearance() { //coding purposes
        //transforms an dictionnary of probabilities to a dictionnary of ranges.
        var sum: Float = 0.0
        for (key, value) in probAppearance.sorted(by: >) {
            probRangeAppearance[key] = sum...(sum + value)
            sum += value
        }
    }

    func getRandomColorBubble() -> Bubble {
        let randomNum = Float.random(in: 0.0...1.0) //creates a random float from 0 to 1
        switch(randomNum) {
        case probRangeAppearance["red"]!:
            return RedBubble()
        case probRangeAppearance["pink"]!:
            return PinkBubble()
        case probRangeAppearance["green"]!:
            return GreenBubble()
        case probRangeAppearance["blue"]!:
            return BlueBubble()
        case probRangeAppearance["black"]!:
            return BlackBubble()
        default:
            return Bubble()
        }
    }
}

class ComplexBubbleGenerator: BubbleGenerator {
    //class used in expert mode

    override func generateBubble() throws -> Bubble {
        var bubble = getRandomColorBubble()
        try assignPosition(bubble: bubble)
        bubble = assignId(bubble: bubble)
//      we delete the animation because it gives problems when tapping on the bubble
        bubblesDict[bubble.tag] = bubble
        return bubble
    }
    override func assignPosition(bubble: Bubble) throws {
        //assign randomly the x position of the bubble
        var overlap = true
        var iterations = 0
        var xPosition = 0
        let yPosition = minY //the bubble will be placed at the top

        while iterations < 500 && overlap {
            xPosition = Int.random(in: minX...maxX - bubble.diametre)
            bubble.setPosition(xPosition: xPosition, yPosition: yPosition, maxYPosition: maxY - bubble.diametre)
            overlap = checkOverlap(bubbleOneFrame: bubble.frame)
            iterations += 1
        }
        guard iterations < 500 else { //if no position was found in 500 iterations
            throw BubbleError.noSpaceScreen
        }
    }

    func updatePosition(by increment: Int) -> [Bubble] {
        //update the position of each bubble by #increment pixels.
        //returns a list of bubbles to be removed
        var deletedBubbles = [Bubble]()
        for (_, bubble) in bubblesDict {
            bubble.frame.origin.y += CGFloat(Float(increment))
            bubble.yPosition += increment
            //if the bottom of the bubble touches max Y, delete the bubble
            if (maxY - bubble.yPosition) <= bubble.diametre {
                deletedBubbles.append(bubble)
            }
        }
        return deletedBubbles
    }
}
