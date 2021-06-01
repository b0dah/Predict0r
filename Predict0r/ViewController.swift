//
//  ViewController.swift
//  Predict0r
//
//  Created by Иван Романов on 27.05.2021.
//

import UIKit
import SwifteriOS
 

class ViewController: UIViewController {
    
    // MARK:- Properties
    let apiKeys: APIKeys = readPlistData(filename: "SecretKeys", type: APIKeys.self) as! APIKeys
    private lazy var swifterInstance = Swifter(consumerKey: self.apiKeys.consumerKey, consumerSecret: self.apiKeys.secretKey)
    
    // Classifier Instance
    let sentimentClassifier = TweetSentimentalClassifier()
    
    // Tweets Storage
    var inputTweets: [TweetSentimentalClassifierInput] = []
    var outputPredictions: [TweetSentimentalClassifierOutput] = []
    
    // Info to display
    lazy var sentimentScore = 0
    lazy var tweetsCountThreshold = 100
    lazy var numberOfTweetsAnalyzed = 0
    
    // UI Propertiers
    private var introViewIsDisplayed = true
    
    // MARK:- Subviews
    
    // Name label
    private lazy var nameLabel: UILabel = {
        
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 48)
        l.textColor = .darkGray
        
        return l
    } ()
    
    // Emoji label
    private lazy var emojiLabel: UILabel = {
        
        let l = UILabel()
        l.font = .systemFont(ofSize: 100)
        l.text = "🤤"
        
        return l
    } ()
    
    // Index label
    private lazy var pointsCountLabel: UILabel = {
        
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 58)
        l.textColor = .gray
        l.text = "10"
        
        return l
    } ()
    
    // Points label
    private lazy var pointsLabel: UILabel = {
        
        let l = UILabel()
        l.font = .systemFont(ofSize: 25)
        l.textColor = .gray
        l.text = "points"
        
        return l
    } ()
    
    private lazy var pointsStackView: UIStackView = {
        
        let sv = UIStackView(arrangedSubviews: [pointsCountLabel, pointsLabel])
        
        sv.axis = .vertical
        sv.spacing = 0
        
        sv.distribution = .fill
        sv.alignment = .center
                
        return sv
    } ()
    
    // Analyzed Tweets Count label
    private lazy var analyzedTweetsCountLabel: UILabel = {
        
        let l = UILabel()
        l.font = .systemFont(ofSize: 25)
        l.textColor = .gray
        l.text = "by 100 tweets analyzed"
        
        return l
    } ()
    
    private lazy var infoContainerView: UIStackView = {
        
        let sv = UIStackView(arrangedSubviews: [nameLabel, emojiLabel, pointsStackView, analyzedTweetsCountLabel])
        sv.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        sv.isLayoutMarginsRelativeArrangement = true
        
        sv.axis = .vertical
        sv.spacing = 10
        
        sv.distribution = .fillEqually
        sv.alignment = .center
                
        return sv
    } ()
    
    // Name TextField
    private lazy var nameTextField: UITextField = {
        
        let tf = UITextField()
        
        // Measures
        tf.setWidth(UIScreen.main.bounds.width)
        tf.setHeight(UIScreen.main.bounds.height / 15)
        
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.font = .systemFont(ofSize: 19)
        tf.textColor = .gray
        
        tf.placeholder = "How do people feel about..."
        
        return tf
    } ()
    
    // Predict Button
    private lazy var predictButton: UIButton = {
        
        let b = UIButton(type: .system)
        b.backgroundColor = .white
        b.setTitleColor(.systemGreen, for: .normal)
        b.setTitle("Predict", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 22)
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor.systemGreen.cgColor
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        // Measures
        b.setWidth(UIScreen.main.bounds.width / 3)
        b.setHeight(50)

        b.layer.cornerRadius = 12
        
        // Action
        b.addTarget(self, action: #selector(self.handlePredictButtonTap), for: .touchUpInside)
        
        return b
    } ()
    
    // Main Container
    private lazy var mainContainerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [infoContainerView, nameTextField, predictButton])
        sv.axis = .vertical
        sv.spacing = 30
        
        sv.distribution = .fill
        sv.alignment = .center
        
        return sv
    } ()
    
    // Introduction View
    private lazy var introView: UIView = {
        let v = UIView()
        v.backgroundColor = .appBackground
        
        let inviteLabel = UILabel()
        inviteLabel.textColor = .gray
        inviteLabel.font = .boldSystemFont(ofSize: 22)
        inviteLabel.textAlignment = .center
        inviteLabel.text = "Choose a company to analyze\n⬇️"
        
        v.addSubview(inviteLabel)
        inviteLabel.center(inView: v)
        
        return v
    } ()

    // MARK:- LC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View Setup
        self.configureAppearence()
        self.setupSubviews()

    }
    
    // MARK:- Actions
    @objc private func handlePredictButtonTap() {
        
//        if let searchText = self.nameTextField.text {
//            // API request
//            self.fetchTweetsFor(searchText: searchText)
//        }

        self.sentimentScore = Int.random(in: -15...15)
        self.updateUI(with: self.sentimentScore)
        
        if !self.introView.isHidden { self.introView.isHidden = true }

    }
    
    // MARK:- API
    private func fetchTweetsFor(searchText: String) {
        
        swifterInstance.searchTweet(using: searchText, lang: "en", count: self.tweetsCountThreshold, tweetMode: .extended) { results, metadata in
            
            #warning("if the tweets total less")
            for index in 0..<self.tweetsCountThreshold {
                if let tweetText = results[index]["full_text"].string {
                    let tweetForClassification = TweetSentimentalClassifierInput(text: tweetText)
                    self.inputTweets.append(tweetForClassification)
                }
            }
            
            self.numberOfTweetsAnalyzed = self.inputTweets.count
            print(self.inputTweets.count)
            
            // Make batch predictions
            self.makePrediction(with: self.inputTweets)
        } failure: { error in
            print(error)
        }

    }
    
    // MARK:- Classification
    private func makePrediction(with tweets: [TweetSentimentalClassifierInput]) {
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            predictions.forEach {
                let sentiment = $0.label
                
                switch sentiment {
                case "Pos":
                    self.sentimentScore += 1
                case "Neg":
                    self.sentimentScore -= 1
                default:
                    break
                }
            }
            
            // Emoji for sentiment score
            self.updateUI(with: self.sentimentScore)
            
        } catch let error {
            print("There was an error making prediction \(error)")
        }
    }

    // MARK:- Helpers
    
    private func setupSubviews() {
        
        self.view.addSubview(self.mainContainerStackView)
        self.mainContainerStackView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                           left: self.view.leftAnchor,
                                           bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor,
                                           paddingTop: 40, paddingBottom: 30)
        
        self.view.addSubview(self.introView)
        self.introView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: self.nameTextField.topAnchor, right: self.view.rightAnchor)
    }
    
    private func configureAppearence() {
        
        self.view.backgroundColor = .appBackground
    }
    
    private func updateUI(with sentimentScore: Int) {
        
        self.nameLabel.text = self.nameTextField.text?.trimmingCharacters(in: ["@", "#", " "])
        self.pointsCountLabel.text = String(self.sentimentScore)
        
        var labelColor = UIColor.black
        
        var emojiToDisplay = ""
        switch self.sentimentScore {
        case 20...:
            emojiToDisplay = "😍"
            labelColor = .systemGreen
        case 10...:
            emojiToDisplay = "😊"
            labelColor = .systemYellow
        case 0...:
            emojiToDisplay = "☺️"
            labelColor = .gray
        case Int(-10)...:
            emojiToDisplay = "😐"
            labelColor = .systemOrange
        case Int(-20)...:
            emojiToDisplay = "😕"
            labelColor = .systemRed
        default:
            emojiToDisplay = "😡"
            labelColor = UIColor.black
        }
        
        self.emojiLabel.text = emojiToDisplay
        self.pointsLabel.textColor = labelColor
        self.pointsCountLabel.textColor = labelColor
    }
}

