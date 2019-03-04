//
//  GameScene.swift
//  EndlessRunner
//
//  Created by Himauli Patel on 2019-02-18.
//  Copyright © 2019 Himauli Patel. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    // MARK: Variables/nodes for sprites
    let dinosaur = SKSpriteNode(imageNamed: "dino")
    let background = SKSpriteNode(imageNamed: "BackgroundEndlessRunner")
    let cactus = SKSpriteNode(imageNamed: "cactus")
    var bomb = SKSpriteNode(imageNamed: "bomb")
    var bird = SKSpriteNode(imageNamed: "goose")
    var backgroundNext : SKSpriteNode
    
    // MARK: Variables For Collision
    let dinosaurCategory: UInt32 = 0x1 << 1
    let cactusCategory: UInt32 = 0x1 << 2
    let birdCategory: UInt32 = 0x1 << 4
    
    // MARK: variable for timer
    var cactusTimer: Timer?
    var bombTimer: Timer?
    var birdTimer: Timer?
    
    var deltaTime : TimeInterval = 0
    var lastFrameTime : TimeInterval = 0
    
    // MARK: Dianosaur speed variable
    let DINOSAUR_SPEED:CGFloat = 20
    
    var yn:CGFloat = 0
    var xn:CGFloat = 0
    
    // MARK: Audio node for background music
    let playSound = SKAudioNode(fileNamed: "BackgroundMusic/Victory.mp3")
    
    // MARK: variable for score
    var scoreLabel: SKLabelNode!
    var score = 0{
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // MARK: variables for dealing with game state
    var gameInProgress = true
    
    // MARK: initialize a scene
    override init(size: CGSize) {
        
        // MARK: Background
        // setting up background
        background.position = CGPoint(x:size.width/1.8, y:size.height/1.8)
        background.size = CGSize(width: size.width, height: size.height)
        
        backgroundNext = background.copy() as! SKSpriteNode
        backgroundNext.position =
            CGPoint(x: background.position.x + background.size.width,
                    y: background.position.y)
        
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        addChild(background)
        addChild(backgroundNext)
        
        // MARK: Dinosaur
        // Add a dinosaur to the screen
        self.dinosaur.position = CGPoint(x: size.width*0.10, y: size.height/2 - 100)
        
        //print("Dinosaur x position : \(size.width*0.10)")
        //print("Dinosaur y position : \(size.height/2 - 100)")
        
        dinosaur.size = CGSize(width: 100, height: 100)
        dinosaur.physicsBody = SKPhysicsBody(rectangleOf:self.dinosaur.frame.size)
        dinosaur.physicsBody = SKPhysicsBody(texture: self.dinosaur.texture!, size: self.dinosaur.size)
        dinosaur.physicsBody?.affectedByGravity = false
        self.dinosaur.physicsBody!.isDynamic = false
        
        cactus.physicsBody = SKPhysicsBody(texture: self.cactus.texture!, size: self.cactus.size)
        dinosaur.physicsBody?.affectedByGravity = false
        self.dinosaur.physicsBody!.isDynamic = false
        
        dinosaur.physicsBody?.categoryBitMask = dinosaurCategory
        dinosaur.physicsBody?.contactTestBitMask = cactusCategory
        
        addChild(dinosaur)
        
        //print(dinosaur.size)
        
        // MARK: Play background music
        playSound.run(SKAction.play())
        self.addChild(playSound)
        
        // MARK: Score lable
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = UIColor.black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: size.width*0.10, y: size.height/2 + 150)
        addChild(scoreLabel)
        
        // MARK: Timers
        // Setting up timers
        cactusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(timer) in self.createCactus()})
        
        birdTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: {(timer) in self.createBird()})
        
        // generate random number between 90 - 110
        // the range will prevent the game from getting over all the time because winning score is 100
        let randomNumber = arc4random_uniform(21) + 90
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(randomNumber), repeats: false, block: {(timer) in self.generateBomb()})
        
        print("Random number is: \(randomNumber)")
        //print("Width & height :\(size.width) \(size.height)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveSprite(sprite : SKSpriteNode, nextSprite : SKSpriteNode, speed : Float) -> Void
    {
        var newPosition = CGPoint()
        
        // For both the sprite and its duplicate:
        for spriteToMove in [sprite, nextSprite]
        {
            // Shift the sprite leftward based on the speed
            newPosition = spriteToMove.position
            newPosition.x -= CGFloat(speed * Float(deltaTime))
            spriteToMove.position = newPosition
            
            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if spriteToMove.frame.maxX < self.frame.minX {
                
                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                spriteToMove.position =
                    CGPoint(x: spriteToMove.position.x +
                        spriteToMove.size.width * 2,
                            y: spriteToMove.position.y)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        jump()
    }
    
    // function to make dinosaur jump up on click
    func jump() {
        dinosaur.texture = SKTexture(imageNamed: "dino")
        let moveUp = SKAction.moveBy(x: 0, y: size.height/2, duration: 0.5)
        let moveDown = SKAction.moveTo(y: size.height/2 - 100, duration: 0.5)
        let sequence = SKAction.sequence([moveUp, moveDown])
        dinosaur.run(sequence)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
        if lastFrameTime <= 0
        {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime
        
        lastFrameTime = currentTime
      
        // Next, move each of the four pairs of sprites.
        // Objects that should appear move slower than foreground objects.
        self.moveSprite(sprite: background, nextSprite:backgroundNext, speed:250.0)
    }
    
    // win function
    func gameWin()
    {
        //print("You win!!!")
        
        // set the state variable to false - to stop calculating score
        self.gameInProgress = false
        
        // play win music
        let winSound = SKAction.playSoundFileNamed("BackgroundMusic/Win.wav",waitForCompletion: false)
        self.run(winSound)
        
        //  1. Initiate a new scene
        let gameOverScene = GameOverScene(size: self.size, win: true)
        gameOverScene.scaleMode = self.scaleMode
        
        // 2. Configure the "Animation" between screens
        let transitionEffect = SKTransition.flipHorizontal(withDuration: 0.5)
        
        // 3. Show the scene
        self.view?.presentScene(gameOverScene, transition: transitionEffect)
    }

    // function to calculate score
    @objc func calculateScore()
    {
        // calculate the score only if the game is in progress
        if gameInProgress == true
        {
            self.score = self.score + 5
            
            // Update the score lable
            scoreLabel?.text = "Score: \(score)"
            
            //print("New Score: \(self.score)")
            
            // MARK: Winner Condition
            if score == 100 {
                gameWin()
            }
        }
    }
    
    // MARK: Non-moving Obstacle generation
    func createCactus()
    {
        // setting up cactus
        let cactcus = SKSpriteNode(imageNamed: "cactus")
        cactcus.size = CGSize(width: 50, height: 70)
        
        let xx = size.width - cactcus.size.width
        let yy = size.height/2 - 120
        
        //print("Height: \(size.height)")
        //print("xx : \(xx)")
        
        cactcus.position = CGPoint(x: xx , y: yy)
        cactcus.physicsBody = SKPhysicsBody(rectangleOf: cactcus.size)
        cactcus.physicsBody?.affectedByGravity = false
        
        // For collision
        cactcus.physicsBody?.categoryBitMask = cactusCategory
        cactcus.physicsBody?.contactTestBitMask = dinosaurCategory
        cactcus.physicsBody?.collisionBitMask = 0
        
        addChild(cactcus)
        
        //MARK: REMOVE CATCUS
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 3)
        let sequence = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        cactcus.run(sequence)
        
        // Calculate the score
        perform(#selector(calculateScore), with: nil, afterDelay: 3)
    }
    
    // MARK: Moving Obstacle
    func createBird()
    {
        // setting up bird
        let bird = SKSpriteNode(imageNamed: "goose")
        bird.size = CGSize(width: 50, height: 70)
        
        let xx = size.width
        let yy = size.height/2

        //print("Height: \(size.height)")
        //print("xx : \(xx)")

        bird.position = CGPoint(x: xx , y: yy)
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.affectedByGravity = false
        
        //For collision
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = dinosaurCategory
        bird.physicsBody?.collisionBitMask = 0
        
        addChild(bird)
        
        //MARK: REMOVE CATCUS
        var xPosition = CGFloat(arc4random_uniform(UInt32((size.width))))
        //print("Bird xPosition: \(xPosition)")
        let yPosition = CGFloat(arc4random_uniform(UInt32((size.height))))
        //print("Bird yPosition: \(yPosition)")
        
        // make xPosition positive to make it move left always
        if (xPosition < 0)
        {
            xPosition = -xPosition
        }
        
        let moveUp = SKAction.moveBy(x: -xPosition, y: yPosition, duration: 1.5)
        let moveDown = SKAction.moveBy(x: -xPosition, y: -yPosition, duration: 1.5)
        
        let sequence = SKAction.sequence([moveUp, moveDown, SKAction.removeFromParent()])
        bird.run(sequence)
        
    }
    
    // MARK: Destruction item
    func generateBomb()
    {
        // generate the bomb only if the game is in progress
        if gameInProgress == true
        {
            // setting up a bomb
            var randomX = Int(arc4random_uniform(UInt32(size.width)))
            var randomY = Int(arc4random_uniform(UInt32(size.height)))
            bomb.position = CGPoint(x: size.width - bomb.size.width, y: CGFloat(randomY))
            bomb.size = CGSize(width: 100, height: 100)
            
            // hitbox for bomb
            let bombHitbox = CGSize(width: bomb.size.width, height: bomb.size.height)
            bomb.physicsBody = SKPhysicsBody(rectangleOf: bombHitbox)
            bomb.physicsBody?.isDynamic = false
            bomb.name = "bomb"
            
            addChild(bomb)
            
            // play the bomb blast sound
            let bombSound = SKAction.playSoundFileNamed("BackgroundMusic/BombBlast.wav",waitForCompletion: false)
            self.run(bombSound)
            
            // calling game over function when bomb blasts
            gameOver()
        }
    }
   
    // Game over function
    func gameOver()
    {
        // make the progress false
        gameInProgress = false
        
        // 1. Initiate a new scene
        let gameOverScene = GameOverScene(size: self.size, win: false)
        gameOverScene.scaleMode = self.scaleMode
        
        // 2. Configure the "Animation" between screens
        let transitionEffect = SKTransition.flipHorizontal(withDuration: 0.5)
        
        // 3. Show the scene
        self.view?.presentScene(gameOverScene, transition: transitionEffect)
    }
    
    // MARK: detecting collision
    func didBegin(_ contact: SKPhysicsContact) {
        
        //print("Contact!!!")
        
        if contact.bodyA.categoryBitMask == cactusCategory {
            
            // remove Cactus and Dinosaur after collision
            contact.bodyA.node?.removeFromParent()
            dinosaur.removeFromParent()
            self.gameOver()
        }
        if contact.bodyB.categoryBitMask == cactusCategory {
            
            // remove Cactus and Dinosaur after collision
            contact.bodyB.node?.removeFromParent()
            dinosaur.removeFromParent()
            self.gameOver()
        }
        if contact.bodyA.categoryBitMask == birdCategory {
            
            // remove Bird and Dinosaur after collision
            contact.bodyA.node?.removeFromParent()
            dinosaur.removeFromParent()
            self.gameOver()
        }
        if contact.bodyB.categoryBitMask == birdCategory {
            
            // remove Cactus and Dinosaur after collision
            contact.bodyB.node?.removeFromParent()
            dinosaur.removeFromParent()
            self.gameOver()
        }
    }
}
