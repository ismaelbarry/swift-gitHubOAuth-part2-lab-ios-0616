//
//  LoginViewController.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Locksmith
import SafariServices // Import the Safari Services framework to use SFSafariViewController.

// Class directs the user for authorization and authentication.
class LoginViewController: UIViewController {
    
    // You will need a reference to the safari view controller from a couple of methods within the LoginViewController class.
    var safariViewController: SFSafariViewController!
    
    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var imageBackgroundView: UIView!

    let numberOfOctocatImages = 10
    var octocatImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observer:
        // The observer is the LoginViewController; The selector is the method you just created above; The name is the name you used for the post notification in the app delegate; The object is nil.
        // How it works: The Observer is this 'LoginViewController.' The selector is the 'safariLogin function.' The name is any notification that has the name 'Close safari view controller.' Basically--we are waiting for the notification call from the AppDelegate to get the green light to run the safariLogin function. 'safariLogin' only gets called when we get that notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.safariLogin(_:)), name: Notification.closeSafariVC, object:nil)
        
        setUpImageViewAnimation()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if imageBackgroundView.layer.cornerRadius == 0 {
            
            configureButton()
        }
    }
    
    
    @IBAction func loginButtonTapped(sender: UIButton) {
    
        let url = NSURL(string: GitHubAPIClient.URLRouter.oauth)
        
        guard let unwrappedurl = url else { fatalError("Invalid URL.") }
        
        // Initialize a SFSafariViewController using the url
        self.safariViewController = SFSafariViewController(URL: unwrappedurl)
        
        self.presentViewController(self.safariViewController, animated: true, completion: nil)
  
    }
    
    // Add a method called safariLogin that takes one argument called notification of type NSNotification and returns nothing.
    func safariLogin(notification : NSNotification) {
        
        // Get the absolute URL value from the notification argument and print it in the debugger.
        guard let urlValue = notification.object as? NSURL else { fatalError("Invalid conversion of NSNotification Object to String") }
        let urlValueString = urlValue.absoluteString
        print(urlValueString)
        
        GitHubAPIClient.startAccessTokenRequest(url: urlValue) { (canStartAccess) in
            
            if canStartAccess == true {
                
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.closeLoginVC, object: urlValue)
            } else {
             
                return
            }
        }
        
        self.safariViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: Set Up View
extension LoginViewController {
    
    private func configureButton() {
        
        self.imageBackgroundView.layer.cornerRadius = 0.5 * self.imageBackgroundView.bounds.size.width
        
        self.imageBackgroundView.clipsToBounds = true
    }
    
    private func setUpImageViewAnimation() {
        
        for index in 1...numberOfOctocatImages {
            
            if let image = UIImage(named: "octocat-\(index)") {
            
                octocatImages.append(image)
            }
        }
        
        self.loginImageView.animationImages = octocatImages
        
        self.loginImageView.animationDuration = 2.0
        
        self.loginImageView.startAnimating()
    }
}