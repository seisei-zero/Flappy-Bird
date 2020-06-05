//
//  ViewController.swift
//  FlappyBird
//
//  Created by 林正悟 on 2020/06/02.
//  Copyright © 2020 seisei-zero. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let skView = self.view as! SKView
//as!を使用する事によってViewController内のviewの型をUIViewControlleからSKViewへと変換している
        skView.showsFPS = true
        skView.showsNodeCount = true
        let scene = GameScene(size:skView.frame.size)
//GameSceneをskViewの上に載せる事によりゲーム内のオブジェクト(node)が使えるようになる。GameScene(size:skView.frame.size)はsizeの初期値にskView.frame.sizeを代入したクラスGameSceneのインスタンスという理解で良いか？？？？？？？？？？？？？？？？？？？GameSceneクラスを分けているのはなぜ？この下に追記してはいけないのか？
        
        skView.presentScene(scene)
        
    }
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }

}


