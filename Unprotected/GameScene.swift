//
//  GameScene.swift
//  Unprotected
//
//  Created by Fumlar on 2017-02-20.
//  Copyright © 2017 Fumlar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var earth = SKSpriteNode()
    var touchInProgress = false
    var earthShield = SKSpriteNode()
    let objectRelativeScale = CGFloat(0.0002)
    let initialShieldOffset = CGFloat(-1.82)
    let rotationAngle = CGFloat(M_PI / 32)
    let rotationDuration = TimeInterval(3)
    
    override func didMove(to view: SKView) {
        let earthTexture = SKTexture(imageNamed: "EarthFG.png")
        let earthShieldTexture = SKTexture(imageNamed: "EarthShieldSingle.png")
        earth = SKSpriteNode(texture: earthTexture)
        earthShield = SKSpriteNode(texture: earthShieldTexture)
        earth.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        earthShield.position = earth.position
        earth.setScale(self.frame.size.width * objectRelativeScale)
        earthShield.setScale(earth.xScale)
        earthShield.zRotation = initialShieldOffset
        earth.physicsBody = SKPhysicsBody()
        self.addChild(earth)
        self.addChild(earthShield)
        //let shieldRotation = SKAction.rotate(byAngle: rotationAngle, duration: rotationDuration)
        //let repeatedShieldAnimation = SKAction.repeatForever(shieldRotation)
        
    }
    
    func toggleRotationClockwise(object: SKSpriteNode) {
        object.zRotation -= rotationAngle
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInProgress = true
        //earthShield.run()
        //earthShield.zRotation -= 0.1
        
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInProgress = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touchInProgress = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if touchInProgress {
            toggleRotationClockwise(object: earthShield)
        }
    }
}
