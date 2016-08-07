//
//  AppDelegate.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        return true
    }

    // Once the user successfully completes authorization, the callback you provided in your GitHub account is used to trigger the URL Scheme you provided in your project settings. Additionally, the safari view controller calls a UIApplicatioDelegate method called application(_:open:options:) that passes a URL containing a temporary code received from the GitHub callback.
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        // Get the value for the key "UIApplicationOpenURLOptionsSourceApplicationKey" from the options dictionary.
        if let value = options["UIApplicationOpenURLOptionsSourceApplicationKey"] {
            
            // If the value equals "com.apple.SafariViewService", return true.
            if String(value) == "com.apple.SafariViewService" {
            
                // Post notification
                // Add a post notification immediately before the return. Use your Notifications struct from your Constants file to provide the name .closeSafariVC. Pass the value from the incoming url argument to the object parameter of the notification.
                // Note: As mentioned above, the incoming url argument value contains a temporary code that we need to proceed with the GitHub authentication process.
                // (Example: Posts a notification saying, "HEY! SOMETHING HAPPENED!". An observer of the notification will be notified somewhere else in the application.)
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.closeSafariVC, object:url)
                
                return true
            }
                
            else {
                
                return false
            }
        }
        return true 
    }
}