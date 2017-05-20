//
//  BufferScreenViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/26/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import Lottie

class BufferScreenViewController: UIViewController, NVActivityIndicatorViewable{
    
    var game: Game!
    var teamID: String?
    var gameID: String?
    var ref: FIRDatabaseReference!
    var turnsArray: [Any?] = []
    var users: [String] = []
    var currentUser: String?
    var newGame = false
    var endGame = false
    var wordFound = false
    var drawingFound = false
    var winnerFound = false
    var counter = 3
    var didStart = true
    var navScreenshot: UIImage?
    var voted = false
    
    @IBOutlet weak var scribbleDotAnim: NVActivityIndicatorView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var readyOutlet: UIButton!
    
    @IBAction func exitButton(_ sender: AnyObject) {
        readyOutlet.isEnabled = false

        let refreshAlert = UIAlertController(title: "Exit", message: "Leave current game and return to main menu?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "BufferToHome", sender: self)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel")
            
                self.readyOutlet.isEnabled = true
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func readyButton(_ sender: AnyObject) {
        if teamID != nil{
            if newGame == true{
                performSegue(withIdentifier: "BufferToWordSelect", sender: self)
                
                
            }
            else if winnerFound == true{
                performSegue(withIdentifier: "ShowEndGame", sender: self)
                
            }
            else if endGame == true{
                performSegue(withIdentifier: "ShowEndGame", sender: self)
                
            }
            else if wordFound == true{
                self.ref.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    let gameData = snapshot.value as? NSDictionary
                    
                    
                    if let gameStatus = gameData?["status"]! as? String{
                        
                        let inplay = "inplay"
                        if gameStatus == inplay{
                            
                            self.performSegue(withIdentifier: "ShowWordToDraw", sender: self)
                        }
                        else{
                            if let user  = FIRAuth.auth()?.currentUser{
                                
                                let label = self.view.viewWithTag(10) as! UILabel
                                label.text = "Searching for games."
                                
                                let userID: String = user.uid
                                self.checkInPlay(teamID: self.teamID!, userID: userID)
                            }
                        }
                    }
                })
            }
            else if drawingFound == true{
                self.ref.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    let gameData = snapshot.value as? NSDictionary
                    
                    
                    if let gameStatus = gameData?["status"]! as? String{
                        
                        let inplay = "inplay"
                        if gameStatus == inplay{
                            
                            
                            self.performSegue(withIdentifier: "ShowDrawToWord", sender: self)
                        }
                        else{
                            if let user  = FIRAuth.auth()?.currentUser{
                                
                                let label = self.view.viewWithTag(10) as! UILabel
                                label.text = "Searching for games."
                                
                                let userID: String = user.uid
                                self.checkInPlay(teamID: self.teamID!, userID: userID)
                            }
                        }
                    }
                })
                
            }
            else{
                
            }
        }
        else{
            
            if(game.images.count != 0){
                
                
                if(game.images.count == 4){
                    
                    performSegue(withIdentifier: "ShowEndGame", sender: sender)
                    
                    
                    
                }
                
                if(game.captions.count > game.images.count){
                    
                    performSegue(withIdentifier: "ShowWordToDraw", sender: sender)
                    
                    
                    
                }
                    
                    
                else{
                    
                    performSegue(withIdentifier: "ShowDrawToWord", sender: sender)
                    
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let pencil = self.view.viewWithTag(111) as! UIImageView
        pencil.isHidden = true
        
        if teamID != nil{
            let label = self.view.viewWithTag(10) as! UILabel
            let type = "Searching for available games..."
            label.text = type
            activityIndicator.startAnimating()
            readyOutlet.isHidden = true
           
            let animview = self.view.viewWithTag(333)! as UIView
            let animationView = LOTAnimationView(name: "alien")!
            
            animationView.frame = CGRect(x: -20, y: 0, width: 360, height: 360)
            animationView.contentMode = .scaleAspectFill
            animationView.loopAnimation = true
            animview.addSubview(animationView)
            
            animationView.play(completion: { finished in
                // Do Something
            })
            
            
        }
        else{
            print(game.captions.count)
            print(game.images.count)
            // Do any additional setup after loading the view, typically from a nib.
            
            
            if(game.images.count != 0){
                let label = self.view.viewWithTag(10) as! UILabel
                var type: String
                
                
                
                if(game.captions.count > game.images.count){
                    type = "Get ready to draw!"
                    label.text = type
                    print("Checkpoint")
                }
                if(game.captions.count == game.images.count){
                    type = "Get ready to type!"
                    label.text = type
                    print("Checkpoint2")
                }
                if(game.images.count == 4){
                    type = "Game finished! View the results."
                    label.text = type
                    print("Checkpoint")
                }
            }
            
        }
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
    
    
    }
    
    func updateCounter() {
        if teamID != nil{
        if  didStart && counter > 0 {
            counter -= 1
        }
        if  didStart && counter == 0{
            didStart = false
            let label = self.view.viewWithTag(10) as! UILabel
            if self.wordFound == true || self.drawingFound == true || self.newGame == true || self.endGame == true{
                activityIndicator.stopAnimating()
                
                let type = "Game found. Click ready to continue."
                label.text = type
                self.readyOutlet.isHidden = false
            }
            else if self.winnerFound == true{
                activityIndicator.stopAnimating()
                let label = self.view.viewWithTag(10) as! UILabel
                label.text = "You Win!"
                
                self.readyOutlet.isHidden = false
            }
            else{
                label.text = "No Games Found"
            }
            
        }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        if teamID != nil{
            ref = FIRDatabase.database().reference()
            
            if let user  = FIRAuth.auth()?.currentUser{
                
                let label = self.view.viewWithTag(10) as! UILabel
                label.text = "Searching for games."
                
                let userID: String = user.uid
                self.currentUser = userID
                 checkEndGame(teamID: teamID!, userID: userID)
                checkNewGame(teamID: teamID!, userID: userID)
               
                checkInPlay(teamID: teamID!, userID: userID)
                
                
                
                
                
            }
            
            
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func checkNewGame(teamID: String, userID: String ){
        ref.child("Teams/\(teamID)/users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            print (data)
            let activeGame: Bool? = data?["activeGame"]! as! Bool?
            if activeGame!{
            }
            else{
                print("check check: \(self.gameID)")
                
                if self.gameID == nil{
                    self.newGame = true
                    self.gameID = "000"
                }
                
            }
        })
    }
    func checkEndGame(teamID: String, userID: String ){
        var array: [String] = []
        let group1 = DispatchGroup()
        group1.enter()
        if teamID == "000000"{
            let query = ref.child("Users/\(userID)/Public").queryOrderedByValue().queryEqual(toValue: true)
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    
                    array = Array(snap.allKeys) as! [String]
                    group1.leave()
                }
            })
            
        }
        else{
            let query = ref.child("Teams/\(teamID)/games").queryOrderedByValue().queryEqual(toValue: true)
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    
                    array = Array(snap.allKeys) as! [String]
                    group1.leave()
                    
                }
            })
            
        }
        group1.notify(queue: DispatchQueue.main, execute: {
            
            for data in array{
                self.ref.child("Games/\(data)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let gameData = snapshot.value as? NSDictionary
                    let userData = gameData?["users"] as! NSDictionary
                    let userArray = Array(userData.allKeys) as! [String]
                    
                    if ((gameData?["winner"]) != nil) {
                        let winnerData = gameData?["winner"]! as! NSDictionary
                        let winnerArray = Array(winnerData.allValues)
                        let winnerIDArray = Array(winnerData.allKeys)
                        print("I CAN SEE YOU")
                        var count = 0
                        var seenCount = 0
                        
                        for n in winnerArray{
                            let arrayData = n as! NSObject
                            let userID = arrayData.value(forKey: "user")! as? String
                            
                            let seen = arrayData.value(forKey: "seen")! as? Bool
                            
                            if seen == true {
                                seenCount += 1
                            }
                            if self.currentUser! == userID!{
                                seenCount += 1
                                if self.gameID == nil{
                                    self.winnerFound = true
                                    self.gameID = data
                                    let winnerID = winnerIDArray[count] as? String
                                    self.ref?.child("Games/\(data)/winner/\(winnerID!)/seen").setValue(true)
                                    print("check 2: \(self.gameID)")
                                    
                                    
                                    print(" \(self.gameID)")
                                    
                                    self.voted = true
                                    
                                    
                                    
                                    
                                    
                                    
                                    //all users seen result && all winners seen win screen, tag game as done
                                    if seenCount == winnerArray.count{
                                        let gameStatus = gameData?["status"]! as? String
                                        if gameStatus == "didFinish"{
                                            self.ref?.child("Teams/\(self.teamID!)/games/\(self.gameID!)").setValue(false)
                                            
                                            if (teamID) == "000000"{
                                                for user in userArray{
                                                    self.ref?.child("Users/\(user)/Public/\(self.gameID!)").setValue(false)
                                                    
                                                }
                                            }
                                        }
                                    }}
                                count += 1
                            }}
                    }
                    
                    if let gameStatus = gameData?["status"]! as? String{
                        print(gameStatus)
                        
                        if gameStatus == "ended"{
                            if let timestamp = gameData?["time"]! as? TimeInterval{
                                let currentTime = NSDate()
                                
                                print("time winner")
                                print(timestamp)
                                print(currentTime)
                                let converted1 = NSDate(timeIntervalSince1970: timestamp / 1000)
                                print(converted1)
                                let interval = currentTime.timeIntervalSince(converted1 as Date)
                                print(interval)
                                
                                self.ref?.child("Games/\(data)/winner").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.value is NSNull {
                                        if interval > 86400{
                                            self.voted = true
                                            
                                            print("This path was null!")
                                            self.ref?.child("Games/\(data)/turns").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                                                let snapData = snapshot.value as? NSDictionary
                                                
                                                let turnsArray = Array(snapData!.allValues)
                                                var count = 0
                                                var highVote = 0
                                                var tie : [Int] = []
                                                for turnData in turnsArray{
                                                    let dataObject = turnData as! NSObject
                                                    let votes = dataObject.value(forKey: "votes") as! Int
                                                    
                                                    if votes == highVote{
                                                        tie.append(count)
                                                    }
                                                    if votes > highVote{
                                                        highVote = votes
                                                        tie.removeAll()
                                                        tie.append(count)
                                                    }
                                                    
                                                    
                                                    count += 1
                                                }
                                                for n in tie{
                                                    let arrayData = turnsArray[n] as! NSObject
                                                    let userID = arrayData.value(forKey: "user")! as? String
                                                    let name = arrayData.value(forKey: "username")! as? String
                                                    print(name)
                                                    print(userID)
                                                    self.ref?.child("Games/\(data)/winner").childByAutoId().setValue(["user": userID!, "username": name!, "seen": false])
                                                }
                                                
                                            })
                                            
                                        }}
                                    else{
                                        self.voted = true
                                    }
                                })
                                
                                
                                
                                
                            }
                            let userData = gameData?["users"]! as? NSDictionary
                            
                            print("poop")
                            var user = ""
                            self.users = Array(userData!.allKeys) as! [String]
                            let value = Array(userData!.allValues) as! [Bool]
                            var count = 0
                            for x in self.users{
                                let userValue = value[count]
                                count += 1
                                user = x
                                if userValue == true{
                                    if user == userID{
                                        print("poop2")
                                        if self.gameID == nil{
                                            
                                            self.gameID = data
                                            self.endGame = true
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    
                })
                
                
            }
            
            
        })
    }
    func checkInPlay(teamID: String, userID: String ){
        var array: [Any?] = []
        var gameIDs: [Any?] = []
        print("taco")
        
        let query = ref.child("Teams/\(teamID)/games").queryOrderedByValue().queryEqual(toValue: true)
        
        print("supreme")
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("This path was null!")
            }
            else {
                
                let snap = snapshot.value! as! NSDictionary
                gameIDs = Array(snap.allKeys)
                print(gameIDs)
                
                
                
                var teamUsers: [Any?] = []
                print("alpha")
                
                print("beta")
                
                for data in gameIDs{
                    array.append(data)
                    print (data)
                    
                    
                    
                    self.ref.child("Games/\(data!)").observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot.value)
                        let gameData = snapshot.value as? NSDictionary
                        
                        
                        if let gameStatus = gameData?["status"]! as? String{
                            print(gameStatus)
                            print(snapshot.childrenCount)
                            let inplay = "inplay"
                            let inuse = "inuse"
                            print(gameStatus)
                            print(inplay)
                            if gameStatus == inplay{
                                self.ref.child("Games/\(data!)/turns").observeSingleEvent(of: .value, with: { (snapshot) in
                                    print(snapshot.childrenCount)
                                    
                                    
                                    
                                    
                                    let n = snapshot.childrenCount
                                    print("hot pretzles remaining: \(n)" )
                                    if n % 2 == 0{
                                        
                                        if self.gameID == nil{
                                           
                                            self.gameID = data as! String!
                                            self.drawingFound = true
                                        }
                                        print("even")
                                    }
                                    else{
                                        if self.gameID == nil{
                                            self.gameID = data as! String!
                                            self.wordFound = true
                                            self.scribbleDotAnim.startAnimating()
                                            
                                            
                                            let circleSpacing: CGFloat = 2
                                            let circleSize = (self.scribbleDotAnim.bounds.size.width - circleSpacing * 2) / 7
                                           let deltaY = (self.scribbleDotAnim.bounds.size.width / 3 - circleSize / 2)
                                            let duration: CFTimeInterval = 1
                                            let beginTime = CACurrentMediaTime()
                                            let beginTimes: [CFTimeInterval] = [0.07, 0.14, 0.21, 0.28, 0.35, 0.42, 0.49]
                                            let timingFunciton = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                            
                                            // Animation
                                            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                                            
                                            animation.keyTimes = [0, 0.5, 1]
                                            animation.timingFunctions = [timingFunciton, timingFunciton, timingFunciton]
                                            animation.values = [deltaY, -deltaY, deltaY]
                                            animation.duration = duration
                                            animation.repeatCount = HUGE
                                            animation.isRemovedOnCompletion = false
                                            
                                            let pencil = self.view.viewWithTag(111) as! UIImageView
                                            // Draw circles
                                            
                                            animation.beginTime = beginTime
                                            pencil.isHidden = false
                                            pencil.layer.add(animation, forKey: "animation")
                                            
                                        }
                                        
                                        print("odd")
                                    }
                                    
                                })
                            }
                            if gameStatus == inuse{
                                if let inuseTime = gameData?["time"]! as? TimeInterval{
                                    let currentTime = NSDate()
                                    
                                    print("time wizard")
                                    print(inuseTime)
                                    print(currentTime)
                                    let converted1 = NSDate(timeIntervalSince1970: inuseTime / 1000)
                                    print(converted1)
                                    let interval = currentTime.timeIntervalSince(converted1 as Date)
                                    print(interval)
                                    if interval > 300{
                                        self.ref?.child("Games/\(data!)/status").setValue("inplay")
                                        self.ref.child("Games/\(data!)/turns").observeSingleEvent(of: .value, with: { (snapshot) in
                                            print(snapshot.childrenCount)
                                            
                                            
                                            
                                            
                                            let n = snapshot.childrenCount
                                            print("hot pretzles remaining: \(n)" )
                                            if n % 2 == 0{
                                                
                                                if self.gameID == nil{
                                                    
                                                    self.gameID = data as! String!
                                                    self.drawingFound = true
                                                }
                                                print("even")
                                            }
                                            else{
                                                if self.gameID == nil{
                                                    
                                                    self.gameID = data as! String!
                                                    self.wordFound = true
                                                }
                                                
                                                print("odd")
                                            }
                                            
                                        })
                                        
                                        
                                    }
                                }
                            }
                        }
                    })
                    
                    
                }
            }
        })
    }
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BufferToWordSelect" {
            let controller = segue.destination as! WordSelectViewController
            controller.teamID = teamID
            
        }
        if segue.identifier == "ShowWordToDraw" {
            let controller = segue.destination as! DrawWordViewController
            if (gameID != nil){
                controller.gameID = gameID
            }
            else{
                controller.game = game
                
            }
        }
        if segue.identifier == "ShowDrawToWord" {
            
            let controller = segue.destination as! CaptionViewController
            if (gameID != nil){
                controller.gameID = gameID
            }
            else{
                controller.game = game
                
            }
        }
        if segue.identifier == "ShowEndGame" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! EndGameViewController
          
            if (gameID != nil){
                targetController.gameID = gameID
                targetController.voted = voted
            }
            else{
                targetController.game = game
                
            }
        }
        if segue.identifier == "BufferToHome" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! HomeViewController
            
            
        }

        
        
    }
}