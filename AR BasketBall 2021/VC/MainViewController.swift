//
//  MainViewController.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 27.10.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var basketBallLabel: UILabel!
    @IBOutlet weak var ARLabel: UILabel!
    @IBOutlet weak var workoutButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var chooseChallenge: UILabel!
    @IBOutlet var arrayButtons: [UIButton]!
    @IBOutlet var arrayLabels: [UILabel]!
    
    
    //MARK: - Properties
    
    var timeLabelsHidden = true
    var isWorkoutChallenge = false
    
    //MARK:  - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Properties of labels
        
        for label in arrayLabels {
            
            label.alpha = 1
            label.textColor = .white
            label.textAlignment = .center
            
        }
        
        basketBallLabel.text = "Basketball"
        basketBallLabel.frame = CGRect(x: view.bounds.midX - 200, y: 330, width: 400, height: 50)
        basketBallLabel.font = UIFont(name: "Gill Sans", size: 65)
        
        chooseChallenge.text = "Choose your challenge"
        chooseChallenge.frame = CGRect(x: view.bounds.midX - 200, y: 370, width: 400, height: 50)
        chooseChallenge.font = UIFont(name: "Gill Sans", size: 20)
        
        ARLabel.text = "AR"
        ARLabel.frame = CGRect(x: view.bounds.midX + 20, y: 465, width: 100, height: 50)
        ARLabel.font = UIFont(name: "Gill Sans", size: 40)
        ARLabel.transform = CGAffineTransform(rotationAngle: .pi / 4)
        
        //Properties of buttons
        
        for button in arrayButtons {
            
            button.alpha = 0.7
            button.layer.cornerRadius = 20
            button.tintColor = .white
            button.layer.borderWidth = 1
            button.backgroundColor = .gray
            
        }
        
        workoutButton.frame = CGRect(x: view.bounds.midX - 150, y: 130, width: 300, height: 50)
        workoutButton.setTitle("Workout", for: .normal)
        
        timerButton.frame = CGRect(x: view.bounds.midX - 150, y: 780, width: 300, height: 50)
        timerButton.setTitle("Timer", for: .normal)
        
        //Animation of ARlabel
        UILabel.animate(withDuration: 2, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
            self.ARLabel.alpha = 0.1
        }
    }
    
    //MARK: - Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToTimer" {
            
            if let viewController = segue.destination as? ViewController {
                timeLabelsHidden = false
                viewController.timeLabelsHidden = timeLabelsHidden
                viewController.timeLabelsHidden = timeLabelsHidden
            }
        }
        
        if segue.identifier == "goToWorkout" {
            
            if let viewController = segue.destination as? ViewController {
                isWorkoutChallenge = true
                viewController.isWorkoutChallenge = isWorkoutChallenge
                viewController.isWorkoutChallenge = isWorkoutChallenge
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func unwind(_segue: UIStoryboardSegue) {
        print(#line, #function)
    }
    
    @IBAction func timerButtonPressed(_ sender: UIButton) {
        
        //Animation of button
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIButton.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(0.20),
                         initialSpringVelocity: CGFloat(6.0),
                         options: UIButton.AnimationOptions.allowUserInteraction,
                         animations: {
                            sender.transform = CGAffineTransform.identity
                            sender.backgroundColor = .orange
                         })
        
        performSegue(withIdentifier: "goToTimer", sender: timerButton)
    }
    
    @IBAction func workoutButtonPressed(_ sender: UIButton) {
        
        //Animation of button
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIButton.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(0.20),
                         initialSpringVelocity: CGFloat(6.0),
                         options: UIButton.AnimationOptions.allowUserInteraction,
                         animations: {
                            sender.transform = CGAffineTransform.identity
                            sender.backgroundColor = .orange
                         })
        
        performSegue(withIdentifier: "goToWorkout", sender: workoutButton)
    }
}
