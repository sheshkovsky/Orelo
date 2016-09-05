//
//  SecondViewController.swift
//  Orelo
//
//  Created by sheshkovsky on 15/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!{
        didSet{
            profileImage.layer.borderWidth = 2
            profileImage.layer.cornerRadius = 50
            profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showEmail()
        showUserProfileImage()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func showEmail() {
        if let user = FIRAuth.auth()?.currentUser {
            usernameLabel.text = user.displayName
        }
    }
    
    func showUserProfileImage() {
        if let user = FIRAuth.auth()?.currentUser {
            let profileImageURL = user.photoURL
            let data = NSData(contentsOfURL: profileImageURL!)
            
            // print("\(user.photoURL)")
            let sendImage = UIImage(data: data!)
            profileImage.image = maskRoundedImage(sendImage!, radius: 50)
        }
    }
    
    func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Signout(sender: UIButton) {
        // working sign out:
        GIDSignIn.sharedInstance().signOut()
        self.performSegueWithIdentifier("signedoutSegue", sender: nil)
        
        // bad sign out: try! FIRAuth.auth()!.signOut()
    }
}



