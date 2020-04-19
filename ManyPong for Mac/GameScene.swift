//
//  GameScene.swift
//  ManyPong for Mac
//
//  Created by Michael McNulty on 8/19/19.
//  Copyright © 2019 MicMacro. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var endgame:Bool = false
    
    var balls = [SKNode()]
    var ballsdx = [Int()]
    var ballsdy = [Int()]
    var ballrad:Int = 20
    @objc func newball(){
        let ball:SKShapeNode = SKShapeNode(circleOfRadius: CGFloat(ballrad))
        ball.fillColor = .red
        ball.strokeColor = .red
        ball.position = CGPoint(x: 0, y:0)
        balls.append(ball)
        ballsdx.append(Int.random(in: 2 ... 5))
        ballsdy.append(Int.random(in: 2 ... 5))
        self.addChild(ball)
    }
    var balltimer:Timer? = nil
    var handleBallsThisTime:Bool = true
    
    var score:Int = 0
    var sl:SKLabelNode?
    
    var paddle:SKShapeNode?
    var paddley:Int = 0
    
    var sW:CGFloat = 0
    var sH:CGFloat = 0
    
    var goUp:Int = 0
    var goDown:Int = 0
    
    var mousehidden:Bool = true
    
    var wall:SKShapeNode?
    
    override func sceneDidLoad() {
        
        NSCursor.hide()
        
        self.backgroundColor = .black
        
        sW = self.size.width
        sH = self.size.height
        
        paddle = SKShapeNode.init(rectOf: CGSize(width: 30, height: sH/4))
        
        sl = SKLabelNode.init(text: "Score: " + String(score))
        sl?.color = .white
        sl?.fontSize = CGFloat(integerLiteral: 20)
        sl?.fontName = "AvenirNext-Bold"
        sl?.position = CGPoint(x: 0, y: (sH/2)-25)
        self.addChild(sl!)
        
        wall = SKShapeNode.init(rectOf: CGSize(width: 30, height: sH))
        wall?.fillColor = .green
        wall?.strokeColor = .green
        wall?.position = CGPoint(x: (sW/2)-15, y: 0)
        self.addChild(wall!)
        
        balltimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.newball), userInfo: nil, repeats: true)
    }
    
    func gameover(){
        balltimer?.invalidate()
        NSCursor.unhide()
        endgame = true
        for ball in balls{
            ball.removeFromParent()
        }
        paddle?.removeFromParent()
        wall?.removeFromParent()
        
        let los = SKLabelNode.init(text: "Score: " + String(score) + ", Cmd+N for New Game")
        los.color = .white
        los.fontSize = CGFloat(integerLiteral: 30)
        los.fontName = "AvenirNext-Bold"
        los.position = CGPoint(x: 0, y: 0)
        self.addChild(los)
    }
    
    func showPaddle(){
        paddle?.fillColor = .white
        paddle?.strokeColor = .white
        let ypos:Int = paddley
        let xpos:Int = (0 - Int(sW/2) + 20) + 30
        paddle?.position = CGPoint(x: xpos, y: ypos)
        self.addChild(paddle!)
    }
    
    func cleanupPaddle(){
        paddle?.removeFromParent()
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        if mousehidden{
            NSCursor.unhide()
            mousehidden = false
        }else{
            NSCursor.hide()
            mousehidden = true
        }
    }
    
    func handleMov(){
        paddley = Int(NSEvent.mouseLocation.y - (sH/2))
        if paddley > (Int(sH/2)){
            paddley = (Int(sH/2))
        }
        if paddley < (0 - Int(sH/2)){
            paddley = (0 - Int(sH/2))
        }
    }
    
    func handleBalls(){
        if !handleBallsThisTime{
            handleBallsThisTime = true
            return
        }
        for ball in balls{
            let i:Int = balls.firstIndex(of: ball)!
            if ball.position.x+CGFloat(ballrad+1) > (sW/2)-30/*-30 to account for the green strip*/ {
                ballsdx[i] *= 0-1
            }
            if ball.position.x-CGFloat(ballrad+1) < 0-(sW/2){
                gameover()
            }
            
            if ball.position.x-CGFloat(ballrad+30+30/*+30 to account for paddle width then again for the blank space between wall and paddle*/) < 0-(sW/2){ // If the paddle's x greater than the ball's x
                if ball.position.x-CGFloat(ballrad+30/*+30 to account for the blank space between wall and paddle*/) > 0-(sW/2){
                    if ball.position.y - CGFloat(ballrad) < (paddle?.position.y)! - (sH/8){ // CURRENTLY PROBLAMATIC WITH LOW DY BALLS
                        if ball.position.y + CGFloat(ballrad) > (paddle?.position.y)!-(sH/4){  // CURRENTLY PROBLAMATIC WITH LOW DY BALLS
                            ball.position.x = (paddle?.position.x)!+15+CGFloat(ballrad)
                            ballsdx[i] = abs(ballsdx[i])
                            score += 1
                            sl?.text = "Score: " + String(score)
                        }
                    }

                    if ball.position.y + CGFloat(ballrad) < (paddle?.position.y)! + (sH/8){ // CURRENTLY PROBLAMATIC WITH LOW DY BALLS
                        if ball.position.y + CGFloat(ballrad) > (paddle?.position.y)!-(sH/4){  // CURRENTLY PROBLAMATIC WITH LOW DY BALLS
                            ball.position.x = (paddle?.position.x)!+15+CGFloat(ballrad)
                            ballsdx[i] = abs(ballsdx[i])
                            score += 1
                            sl?.text = "Score: " + String(score)
                        }
                    }
                }
            }

            
            if ball.position.y+CGFloat(ballrad+1) > sH/2 {
                ballsdy[i] *= 0-1
            }
            if ball.position.y-CGFloat(ballrad+1) < 0-(sH/2){
                ballsdy[i] *= 0-1
            }
            handleBallsThisTime = false
            ball.run(SKAction.move(by: CGVector(dx: ballsdx[i], dy: ballsdy[i]), duration: 0.01666666667))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !endgame{
            cleanupPaddle()
            showPaddle()
            
            handleBalls()
            
            handleMov()
            
        }
        
    }
}
