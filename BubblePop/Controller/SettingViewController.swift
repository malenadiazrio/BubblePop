//
//  SettingViewController.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 3/4/23.
//

import Foundation
import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var nameErrorLabel: UILabel!

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var timeSlider: UISlider!

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var bubbleLabel: UILabel!

    @IBOutlet weak var bubbleSlider: UISlider!

    @IBOutlet weak var playGameButton: UIButton!

    @IBOutlet weak var errorSymbol: UIImageView!

    @IBOutlet weak var gameMode: UISegmentedControl!

    var highScoreData = HighScoreData()
    var alertShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setLastUsedName()
        alertShown = false
        playGameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        playGameButton.setTitleColor(UIColor(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1), for: .normal)
    }

    @IBAction func timeChanged(_ sender: Any) {
        // user changed value in time slider
        timeLabel.text = String(Int(timeSlider.value)) + "s"
        guard alertShown else { //if alert was not shown, show it
            alertShown = true
            checkSettings()
            return
        }
    }

    @IBAction func bubbleChanged(_ sender: Any) {
        // user changed value in maximum number of bubbles slider
        bubbleLabel.text = String(Int(bubbleSlider.value))
        guard alertShown else { //if alert was not shown, show it
            alertShown = true
            checkSettings()
            return
        }
    }

    @IBAction func nameChanged(_ sender: Any) {
        // user changed content of name field
        checkName()
    }

    func setLastUsedName() {
        //retrieve the last used name from user defaults
        do {
            nameTextField.text = try highScoreData.getLastPlayer().name
        }
        catch {
            print(error.localizedDescription)
        }
        checkName()
    }


    func invalidNameDisplay (error: String) {
        // object view settings when the name has an error
        nameErrorLabel.text = error
        errorSymbol.isHidden = false
        playGameButton.isEnabled = false
    }

    func validNameDisplay () {
        // object view settings when the name is valid
        errorSymbol.isHidden = true
        nameErrorLabel.text = ""
        playGameButton.isEnabled = true
    }

    func checkName() {
        //function that cehcks if the name is valid
        guard nameTextField.text != "" else { //check that the name field is not empty
            invalidNameDisplay(error: "Please enter a username")

            return
        }
        validNameDisplay()
    }

    func storeUser() {
        //store the information of the user
        do {
            try highScoreData.storeUser(name: nameTextField?.text ?? "")
        }
        catch {
            print(error.localizedDescription)
        }
    }

    func withDefaultSettings() -> Bool {
        //check that the settings are the default ones
        return timeLabel.text == "60s" && bubbleLabel.text == "15"
    }

    func checkSettings() {
        //code adapted from https://www.appsdeveloperblog.com/how-to-show-an-alert-in-swift/
        // if the user does not use the default setting its high score will not be stored, if not it would not be fair!!
        // Create new Alert
        let dialogMessage = UIAlertController(title: "Confirm", message: "If you change default settings (60s of game and 15 bubbles maximum) the score will not be stored in the high score table.", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
        })

        //Add OK button to a dialog message
        dialogMessage.addAction(ok)

        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }


    @IBAction func infoButtonPressed(_ sender: Any) {
        //code adapted from https://www.appsdeveloperblog.com/how-to-show-an-alert-in-swift/
        // give the instructions
        // Create new Alert
        let dialogMessage = UIAlertController(title: "Instructions", message: "1. Tap a bubble to pop it.\n 2. If you hit the same color twice, you will get 1.5 times the points. \n 3.In expert mode bubbles move while in the classic mode they are static.\n Good Luck!!", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
        })

        //Add OK button to a dialog message
        dialogMessage.addAction(ok)

        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            storeUser()
            let gameVC = segue.destination as? GameViewController
            gameVC?.name = nameTextField.text
            gameVC?.remainingGameTime = Int(timeSlider.value)
            gameVC?.maxNumberBubbles = Int(bubbleSlider.value)
            gameVC?.gameMode = GameMode.init(rawValue: gameMode.selectedSegmentIndex)!
            gameVC?.storeHighScoreBool = withDefaultSettings()
        }
    }


}
