//
//  HomePageViewController.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 23/4/23.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var highScoreButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        highScoreButton.layer.cornerRadius = 10.0
    }
}
