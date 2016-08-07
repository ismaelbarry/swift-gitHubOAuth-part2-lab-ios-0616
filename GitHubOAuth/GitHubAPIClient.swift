//
//  GitHubAPIClient.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith // is a protocol-oriented library for working the keychain.

// Class interacts with the GitHub API.
class GitHubAPIClient {
    
    // MARK: Path Router
    enum URLRouter {
        
        static let repo = "https://api.github.com/repositories?client_id=\(Secrets.clientID)&client_secret=\(Secrets.clientSecret)"
        
        static let token = "https://github.com/login/oauth/access_token"
        
        static let oauth = "https://github.com/login/oauth/authorize?client_id=\(Secrets.clientID)&scope=repo"
        
        static func starred(repoName repo: String) -> String? {
            
            let starredURL = "https://api.github.com/user/starred/\(repo)?client_id=\(Secrets.clientID)&client_secret=\(Secrets.clientSecret)&access_token="
            
            guard let accessToken = GitHubAPIClient.getAccessToken() else { fatalError("Error: probleming unwrapping accessToken in starredRepoName method.") }
            
            // StarredURL needs to be combined with the access token for user account requests.
            return starredURL+accessToken
        }
    }
}


// MARK: Repositories
extension GitHubAPIClient {
    
    class func getRepositoriesWithCompletion(completionHandler: (JSON?) -> Void) {
        
        Alamofire.request(.GET, URLRouter.repo).validate().responseJSON(completionHandler: { response in
            
            switch response.result {
            
            case .Success:
            
                if let data = response.data {
                    completionHandler(JSON(data: data))
                }
                
            case .Failure(let error):
                print("ERROR: \(error.localizedDescription)")
                completionHandler(nil)
            }
        })
    }
}


// MARK: OAuth
extension GitHubAPIClient {
    
    // Method checks if there is a token saved.
    class func hasToken() -> Bool {
        
        if getAccessToken() == nil || getAccessToken() == "" {
            return false
        } else {
            return true
        }
    }
    
    // Start access token request process
    class func startAccessTokenRequest(url url: NSURL, completionHandler: (Bool) -> ()) {
     
        // Use the NSURL extension from the Extensions file to extract the code.
        // let extractedCode = NSURL.getQueryItemValue(url)
        let extractedCode = url.getQueryItemValue(named: "code")
        
        guard let unwrappedExtractedCode = extractedCode else { fatalError("Invalid extracted code error.") }
        
        // Build your parameter dictionary for the request: ["client_id": your client id]; ["client_secret": your client secret]; ["code": temporary code from GitHub]
        let parameterDictionary = ["client_id" : "\(Secrets.clientID)", "client_secret" : "\(Secrets.clientSecret)", "code" : "\(unwrappedExtractedCode)"]
        
        // Build your headers dictionary to receive JSON data back. ["Accept": "application/json"]
        let headersDictionary = ["Accept" : "application/json"]
        
        Alamofire.request(.POST, GitHubAPIClient.URLRouter.token, parameters: parameterDictionary, encoding: ParameterEncoding.JSON, headers: headersDictionary).responseJSON { (response) in
            
            switch response.result{
            case .Success:
                
                // Receive response.
                guard let value = response.result.value else { fatalError("Invalid unwrapped response value.") }
                print("Response from the startAccessToken function in GitHubAPIClient: \(value)")
                
                // Serialize JSON data using SwiftyJSON.
                let json = JSON(value)
                let accessTokenString = json["access_token"].stringValue
                
                // If save succeeded, call the completion handler of startAccessTokenRequest(url:completionHandler:) with the appropriate response.
                self.saveAccess(token: accessTokenString, completionHandler: { (isSaved) in
                    
                    if isSaved == true {
                       
                        print("Token save is successful.")
                        completionHandler(true)
                        
                    } else {
                        
                        print("Error: Token save is unsuccessful.")
                        completionHandler(false)
                        
                    }
                })
                
            case .Failure(let error):
                
                completionHandler(false)
                print(error)
            }
        }
    }
    
    // Save access token from request response to keychain
    private class func saveAccess(token token: String, completionHandler: (Bool) -> ()) {
        
        do {
            // Key is "access token". Value is "token from response". User account is "github".
            try Locksmith.saveData(["access token" : token], forUserAccount: "github")
            // The completionHandler should callback true depending on whether the access token is saved successfully.
            completionHandler(true)
        } catch {
            print(error)
            // The completionHandler should callback false depending on whether the access token is saved successfully.
            completionHandler(false)
        }
    }
    
    // Get access token from keychain.
    private class func getAccessToken() -> String? {
        
        let githubUserAccount = Locksmith.loadDataForUserAccount("github")
        
        guard let unwrappedGithubUserAccount = githubUserAccount else { fatalError("Error: githubUserAccount unwrap failed.") }
        
        guard let accessToken = unwrappedGithubUserAccount["access token"] else { fatalError("Error: Failed to retrieve access token from github user.") }
        
        return String(accessToken)
    }
    
    // Delete access token from keychain
    class func deleteAccessToken(completionHandler: (Bool) -> ()) {
        
    }
}


// MARK: Activity
extension GitHubAPIClient {
    
    class func checkIfRepositoryIsStarred(fullName: String, completionHandler: (Bool?) -> ()) {
        
        guard let urlString = URLRouter.starred(repoName: fullName) else {
            print("ERROR: Unable to get url path for starred status")
            completionHandler(nil)
            return
        }
        
        Alamofire.request(.GET, urlString).validate(statusCode: 204...404).responseString(completionHandler: { response in
            
            switch response.result {
                
            case .Success:
                
                if response.response?.statusCode == 204 {
                
                    completionHandler(true)
                    
                } else if response.response?.statusCode == 404 {
                
                    completionHandler(false)
                    
                }
                
            case .Failure(let error):
            
                print("ERROR: \(error.localizedDescription)")
                completionHandler(nil)
            }
        })
    }
    
    class func starRepository(fullName: String, completionHandler: (Bool) -> ()) {
        
        guard let urlString = URLRouter.starred(repoName: fullName) else {
            print("ERROR: Unable to get url path for starred status")
            completionHandler(false)
            return
        }
        
        Alamofire.request(.PUT, urlString).validate(statusCode: 204...204).responseString(completionHandler: { response in
            
            switch response.result {
            
            case .Success:
            
                completionHandler(true)
                
            case .Failure(let error):
            
                print("ERROR: \(error.localizedDescription)")
                completionHandler(false)
                
            }
        })
    }
    
    class func unStarRepository(fullName: String, completionHandler: (Bool) -> ()) {
        
        guard let urlString = URLRouter.starred(repoName: fullName) else {
            print("ERROR: Unable to get url path for starred status")
            completionHandler(false)
            return
        }
        
        Alamofire.request(.DELETE, urlString).validate(statusCode: 204...204).responseString(completionHandler: { response in
            
            switch response.result {
            
            case .Success:
            
                completionHandler(true)
                
            case .Failure(let error):
            
                print("ERROR: \(error.localizedDescription)")
                completionHandler(false)
            }
        })
    }
}