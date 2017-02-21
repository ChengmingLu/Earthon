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
    var touchInProgress = false
    var earth = SKSpriteNode()
    var earthShield = SKSpriteNode()
    var rock = SKSpriteNode()
    var rockVelocity = CGFloat()
    let objectRelativeScale = CGFloat(0.0002)
    //let rockScale = CGFloat(0.10)
    let rockVelocityScale = CGFloat(0.3)
    let initialShieldOffset = CGFloat(-1.82)
    let rotationAngle = CGFloat(M_PI / 32)
    let rotationDuration = TimeInterval(3)
    
    enum CollisionType: UInt32 {
        case Rock = 1
        case Shield = 2
        case Earth = 4
    }
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        let earthTexture = SKTexture(imageNamed: "EarthFG.png")
        let earthShieldTexture = SKTexture(imageNamed: "EarthShieldSingle.png")
        let rockTexture = SKTexture(imageNamed: "Rock.png")
        earth = SKSpriteNode(texture: earthTexture)
        earthShield = SKSpriteNode(texture: earthShieldTexture)
        rock = SKSpriteNode(texture: rockTexture)
        earth.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        earthShield.position = earth.position
        earth.setScale(self.frame.size.width * objectRelativeScale)
        earthShield.setScale(earth.xScale)
        rock.setScale(earth.xScale)
        earthShield.zRotation = initialShieldOffset
        earth.physicsBody = SKPhysicsBody(circleOfRadius: earth.size.width / 2, center: earth.position)
        earth.physicsBody!.isDynamic = false
        earth.physicsBody!.categoryBitMask = CollisionType.Earth.rawValue
        earth.physicsBody!.contactTestBitMask = CollisionType.Rock.rawValue
        earth.physicsBody!.collisionBitMask = CollisionType.Rock.rawValue
        earthShield.physicsBody = SKPhysicsBody(texture: earthShieldTexture, size: CGSize(width: earthShield.size.width, height: earthShield.size.height))
        earthShield.physicsBody!.isDynamic = false
        earthShield.physicsBody!.categoryBitMask = CollisionType.Shield.rawValue
        earthShield.physicsBody!.contactTestBitMask = CollisionType.Rock.rawValue
        earthShield.physicsBody!.collisionBitMask = CollisionType.Rock.rawValue
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.width / 2)
        rock.physicsBody!.affectedByGravity = false
        rock.physicsBody!.categoryBitMask = CollisionType.Rock.rawValue
        rock.physicsBody!.contactTestBitMask = CollisionType.Earth.rawValue | CollisionType.Shield.rawValue
        rock.physicsBody!.collisionBitMask = CollisionType.Earth.rawValue | CollisionType.Shield.rawValue
        self.addChild(earth)
        self.addChild(earthShield)
        //self.frame:width = 750, height = 1334
        spawnObjectWithVelocity(object: rock, initialPos: CGPoint(x: self.frame.midX - self.frame.width / 2, y: self.frame.midY - self.frame.height / 2))
    }
    
    func spawnObjectWithVelocity(object: SKSpriteNode, initialPos: CGPoint) {
        object.position = initialPos
        self.addChild(object)
        let velocity = CGVector(dx: (self.frame.midX - initialPos.x) * rockVelocityScale, dy: (self.frame.midY - initialPos.y) * rockVelocityScale)
        object.physicsBody!.velocity = velocity
        //print(object.physicsBody!.velocity)
    }
    
    func spawnObjectRandomly() {
    //
    }
    
    
    func toggleRotationClockwise(object: SKSpriteNode) {
        object.zRotation -= rotationAngle
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisionType.Shield.rawValue {
            print("blocked by shield")
        }
        if contact.bodyA.categoryBitMask == CollisionType.Earth.rawValue {
            print("absorbed by earth")
        }
        rock.removeFromParent()
        spawnObjectWithVelocity(object: rock, initialPos: CGPoint(x: self.frame.midX - self.frame.width / 2, y: self.frame.midY - self.frame.height / 2))
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
