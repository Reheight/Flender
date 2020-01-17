//
//  ViewController.swift
//  Flender
//
//  Created by Palmatier, Dustin on 12/19/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import SCSDKLoginKit
import SCLAlertView
import SCSDKBitmojiKit

extension UIImage {
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}

class ViewController: UIViewController, SegmentedProgressBarDelegate {
    @IBOutlet weak var inboxButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    
    // Enum for card states
    enum CardState {
        case collapsed
        case expanded
    }
    
    // Variable determines the next state for card expansion
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    // Variable for card view controller
    var cardViewController: CardViewController!
    
    // Variable for effects visual effect view
    var visualEffectView: UIVisualEffectView!
    
    // Starting and ending card heights ... determined later
    var endCardHeight:CGFloat = 0
    var startCardHeight:CGFloat = 0
    
    // Current state of card
    var cardVisible = false
    
    // Empty property animator array
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    let iconView = SCSDKBitmojiIconView()
    
    func setupCard() {
        inboxButton.layer.cornerRadius = 0.5 * inboxButton.bounds.size.width
        inboxButton.setFAIcon(icon: .FAInbox, forState: .normal)
        searchButton.layer.cornerRadius = 0.5 * searchButton.bounds.size.width
        searchButton.setFAIcon(icon: .FAPlus, forState: .normal)
        // Setup starting and ending card height
        endCardHeight = self.view.frame.height * 0.8
        startCardHeight = 48
        
        // Add Visual effects view
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        // Add CardViewController XIB to bottom of screen clipping bounds so that the corners are rounded
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - startCardHeight, width: self.view.bounds.width, height: endCardHeight)
        cardViewController.view.clipsToBounds = true
        cardViewController.view.layer.cornerRadius = 2
        cardViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        // Add tap and pan recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognzier:)))
        let tapToggleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        cardViewController.exitButton.addGestureRecognizer(tapToggleGestureRecognizer)
        
        cardViewController.exitButton.setFAIcon(icon: .FAIdBadge, forState: .normal)
        cardViewController.exitButton.setFATitleColor(color: .black)
        
        cardViewController.shareButton.setFAIcon(icon: .FAExternalLinkSquare, forState: .normal)
        cardViewController.shareButton.setFATitleColor(color: .black)
        
        cardViewController.positionLabel.setFAIcon(icon: .FAAngleUp, iconSize: 30)
        
        cardViewController.identityView.addSubview(iconView)
        iconView.contentMode = .center
        let screenSize: CGRect = UIScreen.main.bounds
        iconView.frame = CGRect(x: 0,y: 0, width: 65, height: 65)
        iconView.center.x = screenSize.maxX / 2
        iconView.center.y = cardViewController.identityView.frame.maxY / 3
        iconView.layer.borderWidth = 1
        iconView.layer.borderColor = UIColor.black.cgColor
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        cardViewController.logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        cardViewController.shareButton.addTarget(self, action: #selector(shareLink(sender:)), for: .touchUpInside)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-_")
        return text.filter {okayChars.contains($0) }
    }
    
    @objc
    func shareLink(sender: AnyObject) {
        //Set the default sharing message.
        //Set the link to share.
        let externalID = DataStructure.sharedInstance.getExternalId()
        let message = "https://flender.hexhamnetwork.com/add/" + removeSpecialCharsFromString(text: externalID)
        if let link = NSURL(string: "https://flender.hexhamnetwork.com/add/" + removeSpecialCharsFromString(text: externalID))
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc
    func logout() {
        SCSDKLoginClient.unlinkAllSessions { (Bool) in
            if (Bool) {
                DispatchQueue.main.async {
                    let alertViewResponder:SCLAlertViewResponder = SCLAlertView().showError("Logout Successful!", subTitle: "You have successfully logged out of Flender!")
                    alertViewResponder.setDismissBlock {
                        DispatchQueue.main.async {
                            let proceed = self.storyboard?.instantiateViewController(withIdentifier: "InitializationController")
                            self.present(proceed!, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // Handle tap gesture recognizer
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        // Animate card when tap finishes
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
            if (nextState == .collapsed) {
                cardViewController.exitButton.setFAIcon(icon: .FAIdBadge, forState: .normal)
                cardViewController.exitButton.setFATitleColor(color: .black)
                cardViewController.positionLabel.setFAIcon(icon: .FAAngleUp, iconSize: 30)
            } else {
                cardViewController.exitButton.setFAIcon(icon: .FATimesCircle, forState: .normal)
                cardViewController.exitButton.setFATitleColor(color: .black)
                cardViewController.positionLabel.setFAIcon(icon: .FAAngleDown, iconSize: 30)
            }
        default:
            break
        }
    }
    
    // Handle pan gesture recognizer
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        if (nextState == .collapsed) {
            return;
        }
        
        switch recognizer.state {
        case .began:
            // Start animation if pan begins
            startInteractiveTransition(state: nextState, duration: 0.9)
            
        case .changed:
            // Update the translation according to the percentage completed
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / endCardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // End animation when pan ends
            continueInteractiveTransition()
            if (nextState == .collapsed) {
                cardViewController.exitButton.setFAIcon(icon: .FAIdBadge, forState: .normal)
                cardViewController.exitButton.setFATitleColor(color: .black)
                cardViewController.positionLabel.setFAIcon(icon: .FAAngleUp, iconSize: 30)
            } else {
                cardViewController.exitButton.setFAIcon(icon: .FATimesCircle, forState: .normal)
                cardViewController.exitButton.setFATitleColor(color: .black)
                cardViewController.positionLabel.setFAIcon(icon: .FAAngleDown, iconSize: 30)
            }
        default:
            break
        }
    }
    
    @IBOutlet weak var slider: UIView!
    
    private var spb: SegmentedProgressBar!
    private let iv = UIImageView()
    private let images = [#imageLiteral(resourceName: "img1"), #imageLiteral(resourceName: "img2"), #imageLiteral(resourceName: "img3")]
    
    @IBOutlet weak var readBioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        iv.frame = slider.bounds
        iv.contentMode = .scaleAspectFit
        slider.addSubview(iv)
        slider.sendSubview(toBack: iv)
        updateImage(index: 0)
        
        spb = SegmentedProgressBar(numberOfSegments: images.count, duration: 10)
        spb.frame = CGRect(x: 15, y: 15, width: slider.frame.width - 30, height: 4)
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
        spb.padding = 2
        slider.addSubview(spb)
        slider.sendSubview(toBack: spb)
        
        
        view.bringSubview(toFront: slider)
        spb.startAnimation()
        
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedView)))
        
        slider.layer.cornerRadius = 10
 
        // Initialize Card
        setupCard()
        
        denyButton.setFAIcon(icon: .FABan, forState: .normal)
        denyButton.setFATitleColor(color: .white)
        denyButton.layer.cornerRadius = 0.5 * denyButton.bounds.size.width
        
        acceptButton.setFAIcon(icon: .FAPlus, forState: .normal)
        acceptButton.setFATitleColor(color: .white)
        acceptButton.layer.cornerRadius = 0.5 * acceptButton.bounds.size.width
        
        readBioButton.layer.cornerRadius = 0.5 * readBioButton.bounds.size.width
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: slider)
            
            if let touched = touches.first {
                if touched.view != slider {
                    
                } else {
                    
                }
                
            }
            
            if(location.x < 130){
                spb.rewind()
            }
            else {
                spb.skip()
            }
        }
    }

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        updateImage(index: index)
    }
    
    func segmentedProgressBarFinished() {
        for _ in 1...images.count {
            spb.rewind()
        }
    }
    
    @objc private func tappedView() {
        spb.isPaused = !spb.isPaused
    }
    
    private func updateImage(index: Int) {
        iv.image = images[index]
    }
    
    // Animate transistion function
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        // Check if frame animator is empty
        if runningAnimations.isEmpty {
            // Create a UIViewPropertyAnimator depending on the state of the popover view
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    // If expanding set popover y to the ending height and blur background
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.endCardHeight
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    
                case .collapsed:
                    // If collapsed set popover y to the starting height and remove background blur
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.startCardHeight
                    self.visualEffectView.effect = nil
                }
            }
            
            // Complete animation frame
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            // Start animation
            frameAnimator.startAnimation()
            
            // Append animation to running animations
            runningAnimations.append(frameAnimator)
            
            // Create UIViewPropertyAnimator to round the popover view corners depending on the state of the popover
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    // If the view is expanded set the corner radius to 30
                    self.cardViewController.view.layer.cornerRadius = 20
                    
                case .collapsed:
                    // If the view is collapsed set the corner radius to 0
                    self.cardViewController.view.layer.cornerRadius = 2
                }
            }
            
            // Start the corner radius animation
            cornerRadiusAnimator.startAnimation()
            
            // Append animation to running animations
            runningAnimations.append(cornerRadiusAnimator)
            
        }
    }
    
    // Function to start interactive animations when view is dragged
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        
        // If animation is empty start new animation
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Pause animation and update the progress to the fraction complete percentage
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    // Funtion to update transition when view is dragged
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Update the fraction complete value to the current progress
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    // Function to continue an interactive transisiton
    func continueInteractiveTransition (){
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Continue the animation forwards or backwards
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }

}

