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
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var textScoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var arrayLabels: [UILabel]!
    
    // MARK: - Properties
    
    var allThrownBalls: [SCNNode] = []
    let configuration = ARWorldTrackingConfiguration()
    var isWorkoutChallenge = false
    var timeLabelsHidden = true
    
    private var swipeStart = CGPoint()
    private var swipeEnd = CGPoint()
    private var swipeAll = CGPoint()
    private var powerOfThrow: Float = 0
    private var valueProgressView: Float = 0
    private var swipeLocation = CGPoint()
    private var swipeLocationY: Float = 0
    private var timer: Timer!
    
    
    //Check is hoop added
    var isHoopAdded = false {
        didSet {
            
            //If hoop added, disable recognition of vertical planes, because we need an horizontal plane (floor)
            configuration.planeDetection = self.isHoopAdded ? .horizontal : .vertical
            
            //Reset session and remove existing anchors
            sceneView.session.run(configuration, options: .removeExistingAnchors)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timing), userInfo: nil, repeats: true)
        }
    }
    
    var score = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = "\(self.score)"
            }
        }
    }
    
    // 60 Seconds for the Time Challenge
    private var timeLimit = 60 {
        didSet {
            DispatchQueue.main.async {
                if self.timeLimit == 0 {
                    self.timer.invalidate()
                    self.goToFinishVC()
                }
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.isHidden = true
        textTimeLabel.isHidden = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics fps and timing
        sceneView.showsStatistics = true
        
        //Properties of labels
        
        for label in arrayLabels {
            label.alpha = 1
            label.textColor = .white
            label.textAlignment = .center
        }
        
        scoreLabel.frame = CGRect(x: view.bounds.midX - 200, y: 60, width: 100, height: 50)
        scoreLabel.font = UIFont(name: "Gill Sans", size: 45)
        
        textScoreLabel.text = "Score:"
        textScoreLabel.frame = CGRect(x: view.bounds.midX - 200, y: 20, width: 100, height: 50)
        textScoreLabel.font = UIFont(name: "Gill Sans", size: 30)
        
        timeLabel.frame = CGRect(x: view.bounds.midX + 100, y: 60, width: 100, height: 50)
        timeLabel.font = UIFont(name: "Gill Sans", size: 45)
        
        textTimeLabel.text = "Time:"
        textTimeLabel.frame = CGRect(x: view.bounds.midX + 100, y: 20, width: 100, height: 50)
        textTimeLabel.font = UIFont(name: "Gill Sans", size: 30)
        
    }
    
    //MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Detect planes
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        //Show time labels
        if timeLabelsHidden == false {
            textTimeLabel.isHidden = timeLabelsHidden
            timeLabel.isHidden = timeLabelsHidden
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Methods
    
    //Countdown
    @objc private func timing() {
        timeLimit -= 1
        timeLabel.text = String(timeLimit)
    }
    
    func getBallNode() -> SCNNode? {
        
        //Get current frame
        guard let frame = sceneView.session.currentFrame else { return nil }
        
        //Get camera transform
        let cameraTransform = frame.camera.transform
        let matrixCameraTransform = SCNMatrix4(cameraTransform)
        
        let ballNode = BallInit()
        print("added")
        
        //Calculate force for pushing the ball
        let x = -matrixCameraTransform.m31 * powerOfThrow
        let y = -matrixCameraTransform.m32 * powerOfThrow
        let z = -matrixCameraTransform.m33 * powerOfThrow
        
        let forceDirection = SCNVector3(x, y, z)
        print("added direction")
        
        //Apply force
        ballNode.physicsBody?.applyForce(forceDirection, asImpulse: true)
        
        //Assign camera position to ball
        ballNode.simdTransform = cameraTransform
        return ballNode
    }
    
    func getHoopNode() -> SCNNode {
        
        //Get hoop node
        let scene = SCNScene(named: "Hoop.scn", inDirectory: "art.scnassets")!
        let hoopNode = scene.rootNode.clone()
        
        //Add physicsBody to get contact with any balls. Options - for make physics shape, witch repeats the shape of geometry with holes
        hoopNode.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(
            node: hoopNode,
            options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        //Rotate hoopNode to make it vertical
        hoopNode.eulerAngles.x = -.pi / 2
        
        // Add BitMasks to the hoopNode
        hoopNode.physicsBody?.categoryBitMask = CollisionCategory.hoop.rawValue
        hoopNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
        
        return hoopNode
     
    }
    
    func calculatingOfPower() {
        
        let swipePower = Float(swipeStart.y - swipeEnd.y) / Float(sceneView.frame.height)
        powerOfThrow = 25 * (0.1 + swipePower)
        
        progressView.setProgress(powerOfThrow, animated: true)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFinishScreen" {
            
            if let viewController = segue.destination as? FinishViewController {
                viewController.result = score
                print(viewController.result)
            }
        }
    }
    
    func goToFinishVC() {
        performSegue(withIdentifier: "goToFinishScreen", sender: self)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard let nodeAMask = contact.nodeA.physicsBody?.categoryBitMask,
              let nodeBMask = contact.nodeB.physicsBody?.categoryBitMask
        
        else { return }
        
        // When the Ball touch the Point, it disables contact for correct counting of some balls
        if nodeAMask & nodeBMask == CollisionCategory.ball.rawValue & CollisionCategory.point.rawValue {
            
            score += 1
            print(score)
            
            contact.nodeA.physicsBody?.contactTestBitMask = 0
            contact.nodeB.physicsBody?.contactTestBitMask = 0
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
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical
        else {
            return
        }
        
        // Update verticalPlaneNode
        updateVerticalPlaneNode(node, for: planeAnchor)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func userPanned(_ sender: UIPanGestureRecognizer) {
        
        swipeLocation = sender.location(in: sceneView)
        swipeLocationY = Float(swipeLocation.y)
        
        if !isHoopAdded {
            return
        }
        //Calculating of power for throwing the ball
        
        switch sender.state {
        case .began:
            swipeStart = sender.location(in: sceneView)
        case .changed:
            valueProgressView = (Float(sceneView.frame.height) / swipeLocationY) - 1
            progressView.setProgress(valueProgressView, animated: false)
        case .ended:
            swipeEnd = sender.location(in: sceneView)
            
            calculatingOfPower()
            
            //Delete progress (power of throwimg) in progressView, when user ended the swipe
            progressView.setProgress(0, animated: false)
            
            //Add new ball
            guard let newThrownBall = getBallNode() else { return }
            
            sceneView.scene.rootNode.addChildNode(newThrownBall)
            print("ball added")
            
            //Add ball to the array
            allThrownBalls.append(newThrownBall)
            
        default:
            return
        }
            
        //Activate challenge for WorkoutChallenge
        if isWorkoutChallenge == true {
            if allThrownBalls.count > 10 {
                goToFinishVC()
            }
        }
    }
    
    @IBAction func userTapped(_ sender: UITapGestureRecognizer) {
        
        //Check is hoop added
        if isHoopAdded {
            return
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
            
            //Add childNode Floor to the hoopNode
            hoopNode.addChildNode(FloorInit())
            hoopNode.addChildNode(ScorePointInit())
            
            isHoopAdded = true
        }
    }
}
