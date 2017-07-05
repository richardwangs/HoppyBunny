//
//  GameScene.swift
//  Hoppy Bunny
//
//  Created by Mr StealUrGirl on 6/20/17.
//  Copyright © 2017 Mr StealUrGirl. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    var spawnTimer: CFTimeInterval = 0
    var hero : SKSpriteNode!
    var sinceTouch : CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    let scrollSpeed : CGFloat = 100
    var scrollLayer: SKNode!
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    var buttonRestart: MSButtonNode!
    var gameState: GameSceneState = .active
    var scoreLabel: SKLabelNode!
    var points = 0
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
        scrollLayer = self.childNode(withName: "scrollLayer")
        obstacleSource = self.childNode(withName: "obstacle")
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        physicsWorld.contactDelegate = self
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        
        buttonRestart.selectedHandler = {
            
            let skView = self.view as SKView!
            
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            
            scene?.scaleMode = .aspectFill
            
            skView?.presentScene(scene)
        }
        
        buttonRestart.state = .MSButtonNodeStateHidden
        scoreLabel.text = "\(points)"
    }
    
    func updateObstacle(){
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        for obstacle in obstacleLayer.children as! [SKReferenceNode]{
            
            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
            if obstaclePosition.x <= -26{
                
                obstacle.removeFromParent()
            }
        }
        if spawnTimer >= 1.5 - Double(points) * 0.05{
            
            let newObstacle = obstacleSource.copy() as! SKNode
            obstacleLayer.addChild(newObstacle)
            
            let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234 , max: 382))
            
            newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
            
            spawnTimer = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if gameState != .active{return}
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        hero.physicsBody?.applyImpulse(CGVector(dx: 0 , dy:300))
        hero.physicsBody?.applyAngularImpulse(1)
        sinceTouch = 0
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if gameState != .active{return}
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        if velocityY > 400{
            hero.physicsBody?.velocity.dy = 400
        }
        
        if sinceTouch > 0.2{
            let impulse = -2000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        hero.zRotation.clamp(v1: CGFloat(-90).degreesToRadians(), CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(v1: -1, 3)
        
        sinceTouch += fixedDelta
        scrollWorld()
        updateObstacle()
        spawnTimer += fixedDelta
        
    }
    func scrollWorld(){
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        for ground in scrollLayer.children as! [SKSpriteNode]{
            
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            if groundPosition.x <= -ground.size.width / 2 {
                
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
        for cloud in scrollLayer.children as! [SKSpriteNode]{
            
            let cloudPosition = scrollLayer.convert(cloud.position, to: self)
            
            if cloudPosition.x <= -cloud.size.width / 2 {
                
                let newPosition = CGPoint(x: (self.size.width / 2) + cloud.size.width, y:
                    cloudPosition.y)
                
                cloud.position = self.convert(newPosition, to: scrollLayer)
            }
        
    }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Did our hero pass through the 'goal'? */
        if nodeA.name == "goal" || nodeB.name == "goal" {
            
            /* Increment points */
            points += Int(arc4random_uniform(2)+1)
            
            /* Update score label */
            scoreLabel.text = String(points)
            
            /* We can return now */
            return
        }
        
        let heroDeath = SKAction.run({
            self.hero.zRotation = CGFloat(-90).degreesToRadians()
        })
        
        let shakeScene:SKAction = SKAction.init(named: "Shake")!
        
        for node in self.children{
            node.run(shakeScene)
        }
        
        hero.run(heroDeath)
        print("TODO : Add Contact Code")
        
        if gameState != .active {return}
        
        gameState = .gameOver
        
        hero.physicsBody?.allowsRotation = false
        
        hero.physicsBody?.angularVelocity = 0
        
        hero.removeAllActions()
        
        buttonRestart.state = .MSButtonNodeStateActive
    }
}

enum GameSceneState{
    case active , gameOver
}
