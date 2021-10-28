//
//  MainViewController.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 27.10.2021.
//

import UIKit

class MainViewController: UIViewController {

    
    @IBOutlet weak var basketBallLabel: UILabel!
    @IBOutlet weak var ARLabel: UILabel!
    @IBOutlet weak var workoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        basketBallLabel.text = "Basketball"
        basketBallLabel.frame = CGRect(x: view.bounds.midX - 170, y: 350, width: 340, height: 50)
        basketBallLabel.alpha = 1
        basketBallLabel.textColor = .white
        basketBallLabel.textAlignment = .center
        basketBallLabel.font = UIFont(name: "Gill Sans", size: 65)
        
        
        ARLabel.text = "AR"
        ARLabel.frame = CGRect(x: view.bounds.midX + 20, y: 465, width: 100, height: 50)
        ARLabel.alpha = 1
        ARLabel.textColor = .white
        ARLabel.textAlignment = .center
        ARLabel.font = UIFont(name: "Gill Sans", size: 28)
        ARLabel.transform = CGAffineTransform(rotationAngle: .pi / 4)
        
        
        UILabel.animate(withDuration: 2, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
            self.ARLabel.alpha = 0.1
    }
}
    @IBAction func workoutButtonPressed(_ sender: UIButton) {
  performSegue(withIdentifier: "GoToWorkoutGame", sender: workoutButton)
    }
    
}
