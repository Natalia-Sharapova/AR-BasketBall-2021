//
//  FloorInit.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 03.11.2021.
//

import UIKit
import SceneKit

final class FloorInit: SCNNode {
    
    override init() {
        super.init()
        initialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    private func initialisation() {
        
        //Floor geometry
        let floor = SCNPlane(width: 20, height: 20)
        floor.firstMaterial?.diffuse.contents = UIImage(named: "court")
        
        //Get node
        self.geometry = floor
        self.position = SCNVector3(0, -3, -1)
        
        //Add physicsBody to get contact with any balls
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: self))
        
        // Add BitMasks to the floor
        self.physicsBody?.categoryBitMask = CollisionCategory.floor.rawValue
        self.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
        
        //Rotate node
        self.eulerAngles.x = -.pi / 2
    }
}
