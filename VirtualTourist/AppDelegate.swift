//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Lama on 11/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualTouristDataMdel")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapVC = navigationController.topViewController as! LocationsMapViewController
        mapVC.dataController = dataController

        return true
    }

}

