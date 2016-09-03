//
//  MainTabBarController.swift
//  Orelo
//
//  Created by sheshkovsky on 30/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.tintColor = UIColor.whiteColor()
        tabBar.barStyle = .Black
        
        let feedTab = tabBar.items![0] as UITabBarItem
        let recordTab = tabBar.items![1] as UITabBarItem
        let profileTab = tabBar.items![2] as UITabBarItem
        
        feedTab.image = UIImage(named: "iconFeed")
        feedTab.title = "Feed"
        feedTab.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
        recordTab.image = UIImage(named: "iconRecord")
        recordTab.title = "Record"
        recordTab.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        profileTab.image = UIImage(named: "iconProfile")
        profileTab.title = "Profile"
        profileTab.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
