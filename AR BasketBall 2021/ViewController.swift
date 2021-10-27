//
//  ViewController.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 23.10.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    
    // MARK: - Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Properties
    
    let configuration = ARWorldTrackingConfiguration()
    
    //Check if hoop added
    var isHoopAdded = false {
        didSet {
            
            //If hoop added, disable recognition of vertical planes, because we need an horizontal plane (floor)
            configuration.planeDetection = self.isHoopAdded ? .horizontal : .vertical
            
            //Reset session and remove existing anchors
            sceneView.session.run(configuration, options: .removeExistingAnchors)
        }
    }
    
    var score = 0 {
            didSet {
                DispatchQueue.main.async {
                    print("\(self.score)")
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Detect planes
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Methods
    
    func getBallNode() -> SCNNode? {
        
        //Get current frame
        guard let frame = sceneView.session.currentFrame else {
            return nil
        }
        
        //Get camera transform
        let cameraTransform = frame.camera.transform
        let matrixCameraTransform = SCNMatrix4(cameraTransform)
        
        //Ball geomerty
        let ball = SCNSphere(radius: 0.125)
        ball.firstMaterial?.diffuse.contents = UIImage(named: "ball")
        
        //Get ballNode
        let ballNode = SCNNode(geometry: ball)
        
        //Get physics body
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ballNode))
        
        // Add BitMasks to the Ball
        ballNode.physicsBody?.categoryBitMask = CollisionCategory.ball.rawValue
        ballNode.physicsBody?.contactTestBitMask = CollisionCategory.point.rawValue
        ballNode.physicsBody?.collisionBitMask =  CollisionCategory.hoop.rawValue |
                                                  CollisionCategory.floor.rawValue
        
        
        //Calculate force for pushing the ball
        let power = Float(5)
        let x = -matrixCameraTransform.m31 * power
        let y = -matrixCameraTransform.m32 * power
        let z = -matrixCameraTransform.m33 * power
        
        let forceDirection = SCNVector3(x, y, z)
        
        //Apply force
        ballNode.physicsBody?.applyForce(forceDirection, asImpulse: true)
        
        
        //Assign camera position to ball
        ballNode.simdTransform = cameraTransform
        return ballNode
    }
    
    func getHoopNode() -> SCNNode {
        
        //Get node
        let scene = SCNScene(named: "Hoop.scn", inDirectory: "art.scnassets")!
        let hoopNode = scene.rootNode.clone()
        
        //Add physicsBody to get contact with any balls. Options - for make physics shape, witch repeats the shape of geometry with holes
        hoopNode.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(
                node: hoopNode,
                options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        //Rotate hoopNode to vake it vertical
        hoopNode.eulerAngles.x = -.pi / 2
        
        
        // Add BitMasks to the hoopNode
        hoopNode.physicsBody?.categoryBitMask = CollisionCategory.hoop.rawValue
        hoopNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
        
        //Add geometry of scorePoint
        //func getScorePointNode() -> SCNNode
        let scorePoint = SCNSphere(radius: 0.000002)
        
        //Get scorePointNode
        let scorePointNode = SCNNode(geometry: scorePoint)
        scorePointNode.position = SCNVector3(0.05, -0.55, 0.28)
        
        //Add physicsBody to get contact with any balls
        scorePointNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: scorePointNode))
        
        // Add BitMasks to the scorePoint
        scorePointNode.physicsBody?.categoryBitMask = CollisionCategory.point.rawValue
        scorePointNode.physicsBody?.contactTestBitMask = CollisionCategory.ball.rawValue
        
        hoopNode.addChildNode(scorePointNode)
        
        return hoopNode
    }
    
    func getFloorNode() -> SCNNode {
        
        //Add geometry
        let floor = SCNPlane(width: 20, height: 20)
        floor.firstMaterial?.diffuse.contents = UIImage(named: "court")
        
        //Get node
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -3, -1)
        
        //Add physicsBody to get contact with any balls
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: floorNode))
        
        // Add BitMasks to the floor
        floorNode.physicsBody?.categoryBitMask = CollisionCategory.floor.rawValue
        floorNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
        
        //Rotate node
        floorNode.eulerAngles.x = -.pi / 2
        
        return floorNode
    }
    
    //Visualisation vertical plane for tapping and adding hoop
    
    func getVerticalPlaneNode(for anchor: ARPlaneAnchor) -> SCNNode {
        
        //Get the size of the plane
        let extent = anchor.extent
        
        //Get geometry
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor.systemPink
        
        //Get node
        let verticalPlaneNode = SCNNode(geometry: plane)
        verticalPlaneNode.opacity = 0.5
        
        //Rotate node
        verticalPlaneNode.eulerAngles.x = -.pi / 2
        return verticalPlaneNode
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard let nodeAMask = contact.nodeA.physicsBody?.categoryBitMask,
              let nodeBMask = contact.nodeB.physicsBody?.categoryBitMask
        else { return }
        
        // When the Ball touch the ScorePoint, it disables contact
        if nodeAMask & nodeBMask == CollisionCategory.ball.rawValue & CollisionCategory.point.rawValue {

                contact.nodeA.physicsBody?.contactTestBitMask = 0
                contact.nodeB.physicsBody?.contactTestBitMask = 0
                
                // Add Score Score Board
                score += 1
            }
        }
    
    
    //Update vertical plane size to make it bigger
    
    func updateVerticalPlaneNode(_ node: SCNNode, for anchor: ARPlaneAnchor) {
        guard let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else {
            return
        }
        
        //Change planeNode center
        planeNode.simdPosition = anchor.center
        
        //Change planeNode size
        let extent = anchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical
        else {
            return
        }
        //Add the hoop to the center of the detected vertical plane
        node.addChildNode(getVerticalPlaneNode(for: planeAnchor))
    }
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let horizontalPlaneAnchor = anchor as? ARPlaneAnchor, horizontalPlaneAnchor.alignment == .horizontal
        else {
            return
        }
        node.addChildNode(getFloorNode())
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical
        else {
            return
        }
        
        // Update varticalPlaneNode
        updateVerticalPlaneNode(node, for: planeAnchor)
    }
    
    //MARK: - Actions
    
    @IBAction func userTapped(_ sender: UITapGestureRecognizer) {
        
        if isHoopAdded {
            
            //Get ballNode
            guard let ballNode = getBallNode() else {
                return
            }
            
            //Add balls to the camera position
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
        
        else {
            
            //Get location of the tap on the screen
            let location = sender.location(in: sceneView)
            
            //Get first plane closest to us from the array of the hitTest
            guard let result = sceneView.hitTest(location, types: .existingPlaneUsingExtent).first else {
                return
            }
            
            guard let anchor = result.anchor as? ARPlaneAnchor, anchor.alignment == .vertical else {
                return
            }
            //Get the hoopNode and set its coordinates to the point of user touch
            let hoopNode = getHoopNode()

            hoopNode.simdTransform = result.worldTransform
            
            //Rotate hoopNode
            hoopNode.eulerAngles.x -= .pi / 2
            
            sceneView.scene.rootNode.addChildNode(hoopNode)
            isHoopAdded = true
            
        }
    }
}



