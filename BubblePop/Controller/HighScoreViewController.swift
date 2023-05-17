//
//  HighScoreViewController.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 3/4/23.
//

import Foundation
import UIKit

class HighScoreViewController: UIViewController {

    @IBOutlet weak var highScoreTable: UITableView!

    @IBOutlet weak var gameModeSelector: UISegmentedControl!

    let colorArray: [UIColor] = [UIColor(#colorLiteral(red: 0, green: 0.2892872691, blue: 0.6794527769, alpha: 1)), UIColor(#colorLiteral(red: 0.4910306229, green: 0.6756402611, blue: 0.9687640071, alpha: 1)), UIColor(#colorLiteral(red: 0.4325682555, green: 0.8099276078, blue: 0.9731298089, alpha: 1))] //sets the color of the crowns

    var highScores: [HighScoreUser]?
    var highScoreData = HighScoreData()
    var gameMode: GameMode = .classic

    override func viewDidLoad() {
        super.viewDidLoad()
        gameModeSelector.selectedSegmentIndex = gameMode.rawValue
        getHighScores(mode: gameMode)
    }

    func getHighScores (mode: GameMode) { //get and sort the high scores according to the mode selected
        highScores = highScoreData.highScores
        highScores?.sort { $0.getScore(mode: mode) > $1.getScore(mode: gameMode) }
    }


    @IBAction func gameModeChanged(_ sender: Any) {
        gameMode = GameMode.init(rawValue: gameModeSelector.selectedSegmentIndex) ?? .classic
        getHighScores(mode: gameMode)
        highScoreTable.reloadData()
    }

}

extension HighScoreViewController: UITableViewDelegate {
}

extension HighScoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScores?.count ?? 0

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highScoreCell", for: indexPath)

        guard let score = highScores?[indexPath.row] else {
            return cell
        }

        cell.textLabel?.text = score.name
        cell.detailTextLabel?.text = String(score.getScore(mode: gameMode))

        if indexPath.row < 3 { //for the top three users display a crown of different colors
            cell.imageView?.image = UIImage(systemName: "crown.fill")
            cell.tintColor = colorArray[indexPath.row]
        }
        else { //for the rest of the users display a medal
            cell.imageView?.image = UIImage(systemName: "medal.fill")
            cell.tintColor = .lightGray
        }
        cell.setNeedsLayout()
        return cell
    }


}
