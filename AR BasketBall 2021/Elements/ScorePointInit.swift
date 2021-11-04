//
//  ScorePointInit.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 03.11.2021.
//

import UIKit
import SceneKit

final class ScorePointInit: SCNNode {
    
    override init() {
        super.init()
        initialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    private func initialisation() {
        
        //Add geometry of scorePoint
        let scorePoint = SCNSphere(radius: 0.000002)
        
        //Get scorePointNode
        
        self.geometry = scorePoint
        self.position = SCNVector3(0.05, -0.55, 0.28)
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: self))
        
        //Add physicsBody to get contact with any balls
        self.physicsBody?.categoryBitMask = CollisionCategory.point.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.ball.rawValue
}
}
