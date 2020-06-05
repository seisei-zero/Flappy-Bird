//
//  GameScene.swift
//  FlappyBird
//
//  Created by 林正悟 on 2020/06/02.
//  Copyright © 2020 seisei-zero. All rights reserved.
//
//新しくここのクラスGameScene用のファイルを作る意味は？ViewController.swift上に記すのはまずいのか？？？？？？？？？？？？？？？？？？？？？？？？？？？？

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    //なぜbirdだけSKSpriteNodeなのか？
    var itemNode:SKNode!
    
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1 //0...00010 ← << 1は0をひとつ左にずらす
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    
    
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var bestItemScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    //UserDefaults.standardにおいてインスタンスでもないのにクラスからそのままプロパティを持ち出すことができるのか？
    
    override func didMove(to view: SKView){
        
        let audio = SKAudioNode(fileNamed: "bgm.mp3")
        self.addChild(audio)
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        //SKSceneクラスにphysicsWorldクラスがあり、その中のプロパティgravityを設定する事で重力の設定ができる
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        scrollNode = SKNode()
        addChild(scrollNode)
        //スクロールを一括で止めるために親のノードSKNode()を作成←いまいち何をしているのか分からない？？？？？？？？？？？？？？？？？？？？？？？？？？？？
        wallNode = SKNode()
        itemNode = SKNode()
        scrollNode.addChild(wallNode)
        scrollNode.addChild(itemNode)
        //↑なぜscrollNodeがいるのか？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        setupItemScoreLable()
        
        setupScoreLable()
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        //衝突時に呼ばれるメソッド
        if scrollNode.speed <= 0 {
            
            return
        }
        //ここで処理を止め、壁にあったあとに地面にも必ず衝突するのでそこで2度めの処理を行わないようにする
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //何を行なっているのか分からない？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            var bestScore = userDefaults.integer(forKey: "BEST")
            //"BEST"というキーで保存してあるintegerの値を取得するという意味
            
            if score > bestScore{
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                //scoreはキーを持たないのにキーを持つbestScoreに代入しても良いのか？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
                //保存を即座にするメソッド
            }
        }else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            print("itemScoreUp")
            itemScore += 1
            let play = SKAction.playSoundFileNamed("cursor7", waitForCompletion: true)
            self.run(play)
            
            
            itemScoreLabelNode.text = "itemScore:\(itemScore)"
            itemNode.removeAllChildren()
            
            var bestItemScore = userDefaults.integer(forKey: "BESTITEM")
            
            if itemScore > bestItemScore{
                bestItemScore = itemScore
                bestItemScoreLabelNode.text = "Best Score:\(bestItemScore)"
                //scoreはキーを持たないのにキーを持つbestScoreに代入しても良いのか？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
                userDefaults.set(bestItemScore, forKey: "BESTITEM")
                userDefaults.synchronize()
                //保存を即座にするメソッド
                
            }
        }else{
            print("GameOver")
            scrollNode.speed = 0
            //プロパティscrollNode.speedは設定したアクションの速度を表す。又、speeed = 1の時、設定した速度と等しいことを表す。
            bird.physicsBody?.collisionBitMask = groundCategory
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion:{
                //回転が終わった時にbirdのspeedも0にして完全に停止させる
                self.bird.speed = 0
            })
        }
        
    }
    
    func restart() {
        score = 0
        itemScore = 0
        scoreLabelNode.text = "Score:\(score)"
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        //何の速度？bird.speed = 1ではいけないのか？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？←下に鳥の速度との記述がある。
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        //壁を全て取り除いている
        itemNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
        //鳥とスクロールの速度を元に戻している。
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scrollNode.speed > 0 {
            bird.physicsBody?.velocity = CGVector.zero
            //落下速度をベクトルで表している　鳥の速度をゼロにする
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            //鳥に縦方向の力を与える
            
        }else{
            restart()
        }
        
        
        
    }
    
    func setupGround() {
        
        let groundTexture = SKTexture(imageNamed: "ground")
        //SKTextureは物体の質感を扱うクラス、画像を扱うという認識で良い
        groundTexture.filteringMode = .nearest
        //filteringModeプロパティに.nearestと設定すると画質よりも処理速度優先と設定できる。反対は.linear
        
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        //画面のサイズを地面のサイズで割り、余分に2を足す事により画面から地面が切れないように設定している。
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0,duration: 5)
        //左方向に画像を一枚分スクロールさせるアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        //元の位置に戻すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        //左方向に画像を一枚分スクロールさせるアクションと元の位置に戻すアクションを無限に繰り返すアクション
        
        for i in 0..<needNumber {
            //for in文によりスプライトは繰り返される数だけ生産される
            let sprite = SKSpriteNode(texture: groundTexture)
            //解釈としては画像情報を持ったgroundTexture(画像情報を保持するもの)を保持しているスプライト(画像を表示させるためのもの)を作成
            sprite.position = CGPoint(
                x:groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2)
            //SpriteKitにおいて原点は左下である　それぞれの大きさの半分(/2)nodeの中心を配置している
            //いまいちCGFloatが分からない、型なのか？？？？？？？？？？？？？？？？？？？？？？
            sprite.run(repeatScrollGround)
            //スプライトにアクションを設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            sprite.physicsBody?.categoryBitMask = groundCategory
            sprite.physicsBody?.isDynamic = false
            //重力の影響を受けないように設定
            scrollNode.addChild(sprite)
            //画面に表示させる
        }
    }
    func setupCloud() {
        
        let cloudTexture = SKTexture(imageNamed: "cloud")
        //SKTextureは物体の質感を扱うクラス、画像を扱うという認識で良い
        cloudTexture.filteringMode = .nearest
        //filteringModeプロパティに.nearestと設定すると画質よりも処理速度優先と設定できる。反対は.linear
        
        let needNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        //画面のサイズを地面のサイズで割り、余分に2を足す事により画面から地面が切れないように設定している。
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0,duration: 5)
        //左方向に画像を一枚分スクロールさせるアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        //元の位置に戻すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        //左方向に画像を一枚分スクロールさせるアクションと元の位置に戻すアクションを無限に繰り返すアクション
        
        for i in 0..<needNumber {
            //for in文によりスプライトは繰り返される数だけ生産される
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            //解釈としては画像情報を持ったgroundTexture(画像情報を保持するもの)を保持しているスプライト(画像を表示させるためのもの)を作成
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2)
            //SpriteKitにおいて原点は左下である　それぞれの大きさの半分(/2)nodeの中心を配置している
            //いまいちCGFloatが分からない、型なのか？？？？？？？？？？？？？？？？？？？？？？
            sprite.run(repeatScrollCloud)
            //スプライトにアクションを設定する
            scrollNode.addChild(sprite)
            //画面に表示させる
        }
        
    }
    func setupWall() {
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        //一般的に当たり判定の処理を行うに当たり画質優先にした方がいいらしい
        
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        //壁が画面に入り始める所から出終わるところまでの長さ
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0,duration:4)
        
        //壁が画面に入り始める所から出終わるところまで時間
        let removeWall = SKAction.removeFromParent()
        //.removeFromParent()メソッドは自身を取り除くメソッド
        
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        //.sequenceメソッドはmoveWallとremoveWallを続けて行う
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        let slit_length = birdSize.height * 3
        //スリットの幅を設定
        let random_y_range = birdSize.height * 3
        //隙間の位置の振れ幅を設定
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        //壁を下限に設定した時の原点位置の設定
        let createWallanimation = SKAction.run({
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            //登場する直前の壁の原点のxの値
            wall.zPosition = -50
            //奥行きの設定-50に設定すると雲と地面の間になるらしい
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //CGFloat.randomで0からrandom_y_rangeまでのランダム値を生成
            let under_wall_y = under_wall_lowest_y + random_y
            //壁のランダムな高さの設定
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            //下の壁に壁カテゴリーの属性を付加させている。
            under.physicsBody?.isDynamic = false
            //.isDynamic = falseで重力の効果を消している
            wall.addChild(under)
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            //同じnode(物体を構成するフレーム)wallにスプライトを載せている？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            //categoryBitMaskで自身のカテゴリーを設定
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            //contactTestBitMaskで衝突する事を判定するカテゴリーを設定　今回はbirdのカテゴリー
            wall.addChild(scoreNode)
            wall.run(wallAnimation)
            //.runメソッドはspriteにあるのではなくそれを包括しているnodeにある
            self.wallNode.addChild(wall)
            //nodeをそれよりも大きい(親の？)nodeに入れている意味は？何をしている？？？？？？？？？？？？？？？？？？？？？？
        })
        let waitAnimation = SKAction.wait(forDuration: 2)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallanimation, waitAnimation]))
        //.repeatForever()で()内の動作を永遠に繰り返す/.sequence([])で([])内の動作を続けて行う
        wallNode.run(repeatForeverAnimation)
        
    }
    
    func setupBird() {
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        //鳥のスプライトにそれとほぼ同等の大きさの物理体を与える事で物理演算を設定
        bird.physicsBody?.allowsRotation = false
        //ぶつかった時に回転させない
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        bird.run(flap)
        addChild(bird)
        
    }
    func setupScoreLable() {
        score = 0
        scoreLabelNode = SKLabelNode()
        //以下でscoreLabelNodeの中身をいじる
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10,y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        //最終的にaddChildでscoreLabelNodeを表示する
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        
    }
    func setupItemScoreLable(){
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        //以下でscoreLabelNodeの中身をいじる
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10,y: self.frame.size.height - 120)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "itemScore:\(itemScore)"
        //最終的にaddChildでscoreLabelNodeを表示する
        self.addChild(itemScoreLabelNode)
        
        bestItemScoreLabelNode = SKLabelNode()
        bestItemScoreLabelNode.fontColor = UIColor.black
        bestItemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 150)
        bestItemScoreLabelNode.zPosition = 100
        bestItemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        let bestItemScore = userDefaults.integer(forKey: "BESTITEM")
        bestItemScoreLabelNode.text = "Best itemScore:\(bestItemScore)"
        self.addChild(bestItemScoreLabelNode)
    }
    func setupItem() {
        
        let createItemAnimation = SKAction.run({
            let itemTexture = SKTexture(imageNamed: "skyfish")
            itemTexture.filteringMode = .linear
            let item = SKSpriteNode(texture: itemTexture)
            let groundSize = SKTexture(imageNamed: "ground").size()
            let lowest_y = CGFloat(groundSize.height + itemTexture.size().height / 2)
            let random_y = CGFloat.random(in:lowest_y..<self.frame.size.height)
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: random_y)
            //itemの初期位置設定
            item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2)
            item.physicsBody?.categoryBitMask = self.itemCategory
            item.physicsBody?.contactTestBitMask = self.birdCategory
            item.physicsBody?.isDynamic = false
            //itemの物理体の設定
            let wallTexture = SKTexture(imageNamed: "wall")
            let movingDistance = CGFloat(self.frame.size.width * 2 + wallTexture.size().width * 2)
            let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration: 8)
            let removeItem = SKAction.removeFromParent()
            let itemAnimation = SKAction.sequence([moveItem, removeItem])
            item.run(itemAnimation)
            self.itemNode.addChild(item)
        })
        
        let random_time = CGFloat.random(in:8..<12)
        let waitAnimation = SKAction.wait(forDuration: TimeInterval(random_time))
        
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([waitAnimation, createItemAnimation]))
        
        itemNode.run(repeatForeverAnimation)
        
    }
}
