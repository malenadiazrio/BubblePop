//
//  GameViewController.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 3/4/23.
//

import Foundation
import UIKit

enum GameState {
    case countdown
    case running
    case ended
}

enum GameMode: Int {
    case classic = 0
    case expert = 1

}

class GameViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var highScoreLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var gameArea: UIStackView!

    @IBOutlet weak var launchLabel: UILabel!

    @IBOutlet weak var hintLabel: UILabel!

    //user parameters
    var name: String?
    var totalScore: Int = 0
    var highestScore: Int = 0

    //settings parameters
    var maxNumberBubbles: Int = 15
    var remainingGameTime: Int = 60

    //app parameters
    var bubblesPerSecond: Int = 2 //number of bubbles appearing per second
    var maxRefreshRatio: Float = 0.5 //max percentage of bubbles that are updated

    // no-touch variables
    var currNumberBubbles: Int = 0
    var remainingLaunchTime: Int = 3
    var gameState = GameState.countdown
    var gameMode = GameMode.classic
    var velocity = 1.0
    var maxVelocity = 5.0 //8 pixeles each 0.01 seconds
    var storeHighScoreBool = true

    //timers
    var mainTimer = Timer()
    var bubbleTimer = Timer()
    var movementTimer = Timer()

    //model classes
    var bubbleGenerator: BubbleGenerator?
    var highScoreData = HighScoreData()

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialSettings()
        startTimers()
    }

    func setInitialSettings () {
        nameLabel.text = name! //write name
        timeLabel.text = String(remainingGameTime) //write remaining time
        scoreLabel.text = String(Int(totalScore)) //write current score
        highestScore = highScoreData.getHighestScore(mode: gameMode) //get current highest score
        highScoreLabel.text = String(highestScore) //write current highest score
        hintLabel.isHidden = false

        //create bubble generator
        switch (gameMode) {
        case .classic:
            bubbleGenerator = BubbleGenerator()
        case .expert:
            bubbleGenerator = ComplexBubbleGenerator()
        }
        bubbleGenerator?.setLimitsFromFrame(frame: gameArea.frame) //initialize its frame
    }

    func startTimers() {
        //main timer running every second
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            switch self.gameState {
            case .countdown:
                self.countdown()
            case .running:
                self.gameRunning()
            case .ended:
                self.gameEnded()
            }
        })
        //bubble timer controls the rate the bubbles appear in
        bubbleTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(bubblesPerSecond), repeats: true, block: { timer in
                switch self.gameState {
                case .countdown:
                    break
                case .running:
                    self.generateBubble()
                case .ended:
                    self.bubbleTimer.invalidate()
                }
            })
        //movement timer controls the speed of the bubbles in expert mode
        if gameMode == .expert {
            movementTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
                switch self.gameState {
                case .countdown:
                    break
                case .running:
                    self.updateBubblePositions()
                case .ended:
                    self.bubbleTimer.invalidate()
                }
            })
        }
    }

    func countdown() {
        remainingLaunchTime -= 1
        launchLabel.text = String (remainingLaunchTime)
        if remainingLaunchTime == 0 { // when the countdown ends set game state to running
            hintLabel.isHidden = true
            launchLabel.isHidden = true
            gameState = .running
        }
    }

    func gameRunning() {
        remainingGameTime -= 1
        timeLabel.text = String(remainingGameTime)
        if gameMode == .classic { //in classic mdoe refresh bubbles every second
            refreshBubbles()
        }
        else { //update velocity every 10 seconds in expert mode
            if remainingGameTime % 10 == 0 {
                velocity = min(maxVelocity, velocity + 1)
            }
        }
        if remainingGameTime < 10 { //if the time is less than 10 secods display the label in red
            timeLabel.textColor = UIColor.red
        }
        if remainingGameTime == 0 {
            gameState = .ended
        }
    }

    func gameEnded() {
        mainTimer.invalidate()
        removeAllBubbles() //delete all bubbles
        // if storeHighScoreBool { //if the settings were the default ones, store the high score
        updateHighScore()
        //}
        goToHighScoreScreen() //go to high score screen
    }

    func updateHighScore () {
        //update the user's high score
        do {
            try highScoreData.updateUserHighScore(name: name ?? "", score: totalScore, mode: gameMode)
        }
        catch {
            print(error.localizedDescription)
        }
    }


    func generateBubble() {
        //only create the bubble if there are less bubbles than the maximum allowed
        guard(currNumberBubbles < maxNumberBubbles) else {
            return
        }
        currNumberBubbles += 1 //update current number of bubbles
        do { //generate the bubble
            let bubble = try bubbleGenerator?.generateBubble() ?? Bubble()
            bubble.addTarget(self, action: #selector(bubblePressed), for: .touchUpInside)
            self.view.addSubview(bubble)
        }
        catch {
            print("No free space found in screen to create bubble")
        }
    }

    func refreshBubbles() { //classic mode
        //deletes a random number of bubbles and generates new ones
        let ratio = Float.random(in: 0...maxRefreshRatio) //get random number of bubbles
        let numBubblesToRefresh = Int(Float(currNumberBubbles) * ratio)

        for _ in 0...numBubblesToRefresh {
            if let bubble = bubbleGenerator?.randomBubble() { //select random bubble
                removeBubble(bubble: bubble) //remove it
                generateBubble() //create new one
            }
        }
    }

    func updateBubblePositions() { //expert mode
        //updates the position of the bubbles
        guard let bg = bubbleGenerator as? ComplexBubbleGenerator else { //check that the generator is the complex generator
            return
        }
        let removedBubbles = bg.updatePosition(by: Int(velocity)) //update positions
        for bubble in removedBubbles { //remove the bubbles that are already at the floor
            removeBubble(bubble: bubble)
            currNumberBubbles -= 1
        }
    }

    func removeBubble(bubble: UIButton) {
        //removes a bubble
        if let bubbleDown = bubble as? Bubble {
            bubbleDown.flash() //animation
        }
        bubbleGenerator?.removeBubble(id: bubble.tag) //remove it from the dictionnary
        bubble.removeFromSuperview() //remove it from the view
        currNumberBubbles -= 1 //decrease current number of bubbles
    }


    func removeAllBubbles() { //at the end of the game remove all the bubbles
        for (_, bubble) in bubbleGenerator?.bubblesDict ?? [:] {
            removeBubble(bubble: bubble)
        }
    }

    @IBAction func bubblePressed(_ sender: UIButton) {
        //when bubble is pressed, add the score and remove it from the screen
        totalScore += bubbleGenerator?.getScore(id: sender.tag) ?? 0 //add score
        scoreLabel.text = String(Int(totalScore)) //udpate score
        removeBubble(bubble: sender) //remove bubble
        if totalScore > highestScore { //if it is higher than the highest score, update the high score label too
            highScoreLabel.text = String(totalScore)
        }
    }

    func goToHighScoreScreen() { //go to the high score screen
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HighScoreViewController") as? HighScoreViewController
        vc?.gameMode = gameMode //specify the game mode
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
