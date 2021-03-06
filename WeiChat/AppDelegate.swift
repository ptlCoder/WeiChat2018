//
//  AppDelegate.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/10/28.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  var authListener: AuthStateDidChangeListenerHandle?
  
  var locationManager: CLLocationManager?
  var coordinates: CLLocationCoordinate2D?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    
    //Auto Login
    authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
      //只需要运行一次，所以先移除监听
     
      Auth.auth().removeStateDidChangeListener(self.authListener!)
      
      if user != nil {
        if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
          DispatchQueue.main.async {
            self.goToApp()
          }
        }
      }
    })
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    locationManagerStop()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    locationManagerStart()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func goToApp() {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
    
    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
    
    self.window?.rootViewController = mainView
    
  }


}

extension AppDelegate: CLLocationManagerDelegate {
  
  //MARK: - Location Manager
  func locationManagerStart() {
    if locationManager == nil {
      locationManager = CLLocationManager()
      locationManager?.delegate = self
      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
      locationManager?.requestWhenInUseAuthorization()
    }
    
    locationManager?.startUpdatingLocation()
  }
  
  func locationManagerStop() {
    if locationManager != nil {
      locationManager?.stopUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("faild to get Location")
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse:
      manager.startUpdatingLocation()
    case .authorizedAlways:
      manager.startUpdatingLocation()
    case .restricted:
      print("restricted")
    case .denied:
      locationManager = nil
      print("Denied Location")
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    coordinates = locations.last!.coordinate
  }
}
