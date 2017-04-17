//
//  GameScene.swift
//  CiceBird
//
//  Created by formador on 10/4/17.
//  Copyright © 2017 formador. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Variables locales
    var background = SKSpriteNode()
    var bird = SKSpriteNode()
    var pipeFinal1 = SKSpriteNode()
    var pipeFinal2 = SKSpriteNode()
    var limitLand = SKNode()
    var timer = Timer()
    
    //grupos de colision
    let birdGroup : UInt32 = 1
    let objectsGroup : UInt32 = 2
    let gapGroup : UInt32 = 4
    let movinGroup = SKNode()
    
    //grupo de labels
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var gameOver = false
    
    
    //MARK: - movimientos
    override func didMove(to view: SKView) {
        //definimos quien es el delegado para tener un cuenta las colisiones
        self.physicsWorld.contactDelegate = self
        //manipulamos la gravedad
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        self.addChild(movinGroup)
        
        makeLimitLand()
        makeBackground()
        makeLoopPipe1AndPipe2()
        makeBird()
        makeLabel()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup{
            score += 1
            scoreLabel.text = "\(score)"
        }else if !gameOver{
            gameOver = true
            movinGroup.speed = 0
            timer.invalidate()
            makeLabelGameOver()
        }
    }
    
    
    
    //MARK: - inicio de toques en la pantalla
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver{
            //aqui realizamos un reset de la posicion y de la velocidad del pajaro
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        }else{
            resetGame()
        }
    }
    
    //MARK: - actualizacion de la vista
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    
    //MARK: - Utils
    func makeLimitLand(){
        limitLand.position = CGPoint(x: 0, y: -(self.frame.height / 2))
        limitLand.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        limitLand.physicsBody?.isDynamic = false
        limitLand.physicsBody?.categoryBitMask = objectsGroup
        limitLand.zPosition = 2
        self.addChild(limitLand)
    }
    
    
    
    func makeBackground(){
        let backgroundFinal = SKTexture(imageNamed: "bg")
        let moveBackground = SKAction.moveBy(x: -backgroundFinal.size().width, y: 0, duration: 1)
        let replaceBackground = SKAction.moveBy(x: backgroundFinal.size().width, y: 0, duration: 0)
        let moveBackgroudForever = SKAction.repeatForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for c_imagen in 0..<3{
            background = SKSpriteNode(texture: backgroundFinal)
            background.position = CGPoint(x: -(backgroundFinal.size().width / 2) + (backgroundFinal.size().width * CGFloat(c_imagen)), y: 0)
            background.zPosition = 1
            background.size.height = self.frame.height
            background.run(moveBackgroudForever)
            //self.addChild(background)
            self.movinGroup.addChild(background)
        }
    }
    
    func makePipesFinal(){
        //varibales internas
        let gapheight = bird.size.height * 4
        //aqui le decimos que nos vamos a mover una vez que sale la tuberia  tanto para arriba como para abajo un numero entre 2 y la mitad de la pantalla
        let movementAmount = arc4random_uniform(UInt32(self.frame.height / 2))
        //creamos un desplazamiento de la tuberia que esta entre 0 y la mitad de la pantalla pero le resto 1/4 de esta
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        //movemos las tuberias
        let movePipes = SKAction.moveBy(x: -self.frame.width - 200, y: 0, duration: TimeInterval(self.frame.width / 200))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        //Creamos la textura Uno
        let pipeTexture1 = SKTexture(imageNamed: "pipe1")
        pipeFinal1 = SKSpriteNode(texture: pipeTexture1)
        pipeFinal1.position = CGPoint(x: self.frame.width - self.frame.width / 2, y: self.frame.midY + (pipeFinal1.size.height / 2) + (gapheight / 2) + pipeOffset)
        pipeFinal1.physicsBody = SKPhysicsBody(rectangleOf: pipeFinal1.size)
        pipeFinal1.physicsBody?.isDynamic = false
        
        pipeFinal1.physicsBody?.categoryBitMask = objectsGroup
        
        pipeFinal1.run(moveAndRemovePipes)
        pipeFinal1.zPosition = 5
        //self.addChild(pipeFinal1)
        self.movinGroup.addChild(pipeFinal1)
        
        //Creamos la textura Dos
        let pipeTexture2 = SKTexture(imageNamed: "pipe2")
        pipeFinal2 = SKSpriteNode(texture: pipeTexture2)
        pipeFinal2.position = CGPoint(x: self.frame.width - self.frame.width / 2, y: self.frame.midY - (pipeFinal2.size.height / 2) - (gapheight / 2) + pipeOffset)
        pipeFinal2.physicsBody = SKPhysicsBody(rectangleOf: pipeFinal2.size)
        pipeFinal2.physicsBody?.isDynamic = false
        
        pipeFinal2.physicsBody?.categoryBitMask = objectsGroup
        
        pipeFinal2.run(moveAndRemovePipes)
        pipeFinal2.zPosition = 5
        //self.addChild(pipeFinal2)
        self.movinGroup.addChild(pipeFinal2)
        
        //grupo de colision que atraviesa el gap / hueco
        makeGapNode(pipeOffset, gapHeight: gapheight, moveAndRemovePipes: moveAndRemovePipes)
        
    }
    
    func makeGapNode(_ pipeOffset : CGFloat, gapHeight : CGFloat, moveAndRemovePipes : SKAction){
        let gap = SKNode()
        gap.position = CGPoint(x:  self.frame.width - self.frame.width / 2, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeFinal1.size.width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(moveAndRemovePipes)
        gap.zPosition = 7
        gap.physicsBody?.categoryBitMask = gapGroup
        self.movinGroup.addChild(gap)
    }
    
    
    func makeBird(){
        //1 -> creacion de las texturas
        let birdTexture1 = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        //2 -> Accion
        let animationBird = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.1)
        //3 -> Accion por siempre
        let makeAnimationForever = SKAction.repeatForever(animationBird)
        //4 -> Asigno la animacion a nuestro SKSpriteNode
        bird = SKSpriteNode(texture: birdTexture1)
        //5 -> asignamos la posicion del bird en el espacio
        bird.position = CGPoint(x: self.frame.midX , y: self.frame.midY + 50)
        //6 -> ejecuta la animacion
        bird.run(makeAnimationForever)
        //6.1 -> posicion espacial zPosition
        bird.zPosition = 15
        //GRUPO DE FISICAS
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        //bird.physicsBody = SKPhysicsBody(texture: birdTexture1, alphaThreshold: 0.5, size: CGSize(width: bird.size.width, height: bird.size.height))
        bird.physicsBody?.isDynamic = true
        
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objectsGroup
        bird.physicsBody?.contactTestBitMask = objectsGroup | gapGroup
        
        bird.physicsBody?.allowsRotation = false
        //7 -> añado a la vista
        self.addChild(bird)
    }
    
    func makeLoopPipe1AndPipe2(){
        //Usamos el timer un objeto que determine cada cuantos segundos debe crearse una tuberia
        timer = Timer.scheduledTimer(timeInterval: 2,
                                     target: self,
                                     selector: #selector(makePipesFinal),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func makeLabel(){
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height / 2 - 90)
        scoreLabel.zPosition = 10
        self.addChild(scoreLabel)
    }
    
    func makeLabelGameOver(){
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "GAME OVER :("
        gameOverLabel.position = CGPoint(x: 0, y: 0)
        gameOverLabel.zPosition = 10
        self.addChild(gameOverLabel)
    }
    
    func resetGame(){
        score = 0
        scoreLabel.text = "0"
        movinGroup.removeAllChildren()
        makeBackground()
        makeLoopPipe1AndPipe2()
        bird.position = CGPoint(x: 0, y: 0)
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        gameOverLabel.removeFromParent()
        movinGroup.speed = 1
        gameOver = false
    }
    
    
    
    
    
    
    
}
