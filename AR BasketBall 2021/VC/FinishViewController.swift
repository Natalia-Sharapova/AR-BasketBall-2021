//
//  FinishViewController.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 29.10.2021.
//

import UIKit

class FinishViewController: UIViewController {
    
    //MARK: - Outlets

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var youFinishedLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet var arrayLabels: [UILabel]!
    
    //MARK: - Properties
    
    var result: Int = 0
    
    //MARK: - LifeCycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Properties for labels
        
        for label in arrayLabels {
            
            label.textColor = .white
            label.textAlignment = .center
            label.layer.cornerRadius = 20
            
        }
        
        youFinishedLabel.frame = CGRect(x: view.bounds.midX - 150, y: 300, width: 300, height: 50)
        youFinishedLabel.layer.borderColor = UIColor.white.cgColor
        youFinishedLabel.font = UIFont(name: "Gill Sans", size: 45)
        youFinishedLabel.text = "You finished!"
        
        resultLabel.frame = CGRect(x: view.bounds.midX - 150, y: 400, width: 300, height: 50)
        resultLabel.layer.borderColor = UIColor.white.cgColor
        resultLabel.font = UIFont(name: "Gill Sans", size: 45)
        
        restartButton.frame = CGRect(x: view.bounds.midX - 150, y: 490, width: 300, height: 50)
        restartButton.backgroundColor = .gray
        restartButton.alpha = 0.7
        restartButton.layer.cornerRadius = 20
        restartButton.tintColor = .white
        restartButton.layer.borderWidth = 1
        
        
        restartButton.layer.borderColor = UIColor.white.cgColor
        restartButton.setTitle("Restart", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultLabel.text = "Your score: \(result)"
    }

    //MARK: - Action
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        restartButton.backgroundColor = .orange
                        
    }
}
