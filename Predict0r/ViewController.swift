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
    lazy var numberOfTweetsAnalyzed = 0
    
    // MARK:- Subviews
    
    // Name label
    private lazy var nameLabel: UILabel = {
        
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 48)
        l.textColor = .darkGray
        l.text = "Apple"
        
        return l
    } ()
    
    // Emoji label
    private lazy var emojiLabel: UILabel = {
        
        let l = UILabel()
        l.font = .systemFont(ofSize: 140)
        l.text = "🤤"
        
        return l
    } ()
    
    // Index label
    private lazy var indexLabel: UILabel = {
        
        let l = UILabel()
        l.font = .systemFont(ofSize: 18)
        l.textColor = .gray
        l.text = "10 points"
        
        return l
    } ()
    
    private lazy var infoContainerView: UIStackView = {
        
        let sv = UIStackView(arrangedSubviews: [nameLabel, emojiLabel, indexLabel])
        sv.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        sv.isLayoutMarginsRelativeArrangement = true
        
        sv.axis = .vertical
        sv.spacing = 10
        
        sv.distribution = .fillEqually
        sv.alignment = .center
        
        sv.backgroundColor = .yellow
        
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
    
    //

    // MARK:- LC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View Setup
        self.configureAppearence()
        self.setupSubviews()

    }
    
    // MARK:- Actions
    @objc private func handlePredictButtonTap() {
        
        if let searchText = self.nameTextField.text {
            // API request
            self.searchTweets(searchText: searchText)
        }
    }
    
    // MARK:- API
    private func searchTweets(searchText: String) {
        
        swifterInstance.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended) { results, metadata in
            
            for index in 0..<100 {
                if let tweetText = results[index]["full_text"].string {
                    let tweetForClassification = TweetSentimentalClassifierInput(text: tweetText)
                    self.inputTweets.append(tweetForClassification)
                }
            }
            
            self.numberOfTweetsAnalyzed = self.inputTweets.count
            print(self.inputTweets.count)
            
            // Make batch predictions
            do {
                let predictions = try self.sentimentClassifier.predictions(inputs: self.inputTweets)
                
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
                var emojiToDisplay = ""
                switch self.sentimentScore {
                case 20...:
                    emojiToDisplay = "😍"
                case 10...:
                    emojiToDisplay = "😊"
                case 0...:
                    emojiToDisplay = "☺️"
                case Int(-10)...:
                    emojiToDisplay = "😐"
                case Int(-20)...:
                    emojiToDisplay = "😕"
                default:
                    emojiToDisplay = "😡"
                }
                
            } catch let error {
                print("There was an error making prediction \(error)")
            }
        } failure: { error in
            print(error)
        }

    }

    // MARK:- Helpers
    
    private func setupSubviews() {
        
        self.view.addSubview(self.mainContainerStackView)
        self.mainContainerStackView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                                           left: self.view.leftAnchor,
                                           bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor,
                                           paddingTop: 40, paddingBottom: 30)
    }
    
    private func configureAppearence() {
        
        self.view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
}

