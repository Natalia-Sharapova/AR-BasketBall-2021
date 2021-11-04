//
//  BallInit.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 03.11.2021.
//

import UIKit
import SceneKit

final class BallInit: SCNNode {
    
    override init() {
        super.init()
        initialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    private func initialisation() {
        
        //Ball geometry
        
        let ball = SCNSphere(radius: 0.125)
        ball.firstMaterial?.diffuse.contents = UIImage(named: "ball")
        
        //Get ballNode
        
        self.geometry = ball
        
        //Get physics body
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self))
        
        //Add BitMasks to the Ball
        
        self.physicsBody?.categoryBitMask = CollisionCategory.ball.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.point.rawValue
        self.physicsBody?.collisionBitMask =  CollisionCategory.hoop.rawValue |
                                              CollisionCategory.floor.rawValue
    }
}
