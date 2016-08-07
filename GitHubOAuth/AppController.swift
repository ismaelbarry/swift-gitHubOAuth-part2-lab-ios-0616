//
//  AppController.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class AppController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    var currentViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialViewController()
        addNotificationObservers()

    }
    
}

// MARK: Set Up
extension AppController {
    
    private func loadInitialViewController() {
        
        if GitHubAPIClient.hasToken() {
            self.currentViewController = loadViewControllerWith(StoryboardID.reposTVC)
            addCurrentViewController(self.currentViewController)
        } else {
            self.currentViewController = loadViewControllerWith(StoryboardID.loginVC)
            addCurrentViewController(self.currentViewController)
        }
        
    }
    
    private func addNotificationObservers() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppController.switchViewController(_:)), name: Notification.closeLoginVC, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppController.switchViewController(_:)), name: Notification.closeReposTVC, object: nil)
        
    }
    
}

// MARK: View Controller Handling
extension AppController {

    private func loadViewControllerWith(storyboardID: String) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch storyboardID {
        case StoryboardID.loginVC:
            return storyboard.instantiateViewControllerWithIdentifier(storyboardID) as! LoginViewController
        case StoryboardID.reposTVC:
            let vc = storyboard.instantiateViewControllerWithIdentifier(storyboardID) as! ReposTableViewController
            let navVC = UINavigationController(rootViewController: vc)
            return navVC
        default:
            fatalError("ERROR: Unable to find controller with storyboard id: \(storyboardID)")
        }
        
        
    }
    
    private func addCurrentViewController(controller: UIViewController) {
        
        self.addChildViewController(controller)
        self.containerView.addSubview(controller.view)
        controller.view.frame = self.containerView.bounds
        controller.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        controller.didMoveToParentViewController(self)
        
    }
    
    func switchViewController(notification: NSNotification) {
        
        switch notification.name {
        case Notification.closeLoginVC:
            switchToViewControllerWith(StoryboardID.reposTVC)
        case Notification.closeReposTVC:
            switchToViewControllerWith(StoryboardID.loginVC)
        default:
            fatalError("ERROR: Unable to match notification name")
        }
        
    }
    
    private func switchToViewControllerWith(storyboardID: String) {
        
        let oldViewController = self.currentViewController
        oldViewController.willMoveToParentViewController(nil)
        
        self.currentViewController = loadViewControllerWith(storyboardID)
        self.addChildViewController(self.currentViewController)
        
        addCurrentViewController(self.currentViewController)
        self.currentViewController.view.alpha = 0
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.currentViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            
        }) { completed in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            self.currentViewController.didMoveToParentViewController(self)
        }
        
    }
    
}