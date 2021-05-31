//
//  ViewController.swift
//  Predict0r
//
//  Created by Иван Романов on 27.05.2021.
//

import UIKit


class ViewController: UIViewController {
    
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
        
        let b = UIButton()
        b.backgroundColor = .white
        b.setTitleColor(.systemGreen, for: .normal)
        b.setTitle("Predict", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 22)
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor.systemGreen.cgColor
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        b.setWidth(UIScreen.main.bounds.width / 3)
        b.setHeight(50)
        b.titleLabel?.text = "Predict"

        b.layer.cornerRadius = 12
        
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
        
        self.configureAppearence()
        self.setupSubviews()
        
        self.emojiLabel.text = "🤤"
        self.predictButton.titleLabel?.text = "Predict"
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

