//
//  AppDelegate.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/08/21.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import SwiftUI
import SDWebImageSVGCoder
import SDWebImageSwiftUI
import SwiftKeychainWrapper
import OneSignal
import Firebase
import DinotisData
import netfox

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	
	static var orientationLock = UIInterfaceOrientationMask.portrait
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

#if DEBUG
        NFX.sharedInstance().start()
        NFX.sharedInstance().ignoreURLs(["https://api-silos.dyte.io"])
#endif
		OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        UNUserNotificationCenter.current().delegate = self

		OneSignal.initWithLaunchOptions(launchOptions)
		OneSignal.setAppId(Configuration.shared.environment.oneSignalAppId)
        OneSignal.setNotificationWillShowInForegroundHandler { notificationReceived, completion in
            let content = notificationReceived.notificationId.orEmpty()
            
            // Check if the notification content has already been displayed
            let notificationIDs = UserDefaults.standard.stringArray(forKey: "DisplayedNotificationIDs") ?? []
            if notificationIDs.contains(content) {
                // Notification has already been displayed, prevent it from being shown again
                completion(nil)
                return
            }
            
            // Notification has not been displayed yet, add its ID to the list and show it
            var updatedIDs = notificationIDs
            updatedIDs.append(content)
            UserDefaults.standard.set(updatedIDs, forKey: "DisplayedNotificationIDs")
            completion(notificationReceived)
        }

		OneSignal.promptForPushNotifications(userResponse: { _ in

		})
		
		SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)

		IQKeyboardManager.shared.enable = true
		IQKeyboardManager.shared.shouldResignOnTouchOutside = true
		IQKeyboardManager.shared.enableAutoToolbar = true

		FirebaseApp.configure()
		
		return true
	}
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // User tapped on notification
            let userInfo = response.notification.request.content.userInfo
            
            guard let payload = (userInfo["custom"] as? [String: String])?["u"] as? String else { return }
            
            if payload.contains("page/payment/settle/booking") {
                
                if let id = payload.components(separatedBy: "/").last {
                    StateObservable.shared.bookId = id
                }
                
                NotificationCenter.default.post(name: .audiencePaymentDetail, object: nil)
                
            } else if payload.contains("page/creator") {
                if let id = payload.components(separatedBy: "/").last {
                    StateObservable.shared.usernameCreator = id
                }
                
                NotificationCenter.default.post(name: .creatorDetail, object: nil)
            } else if payload.contains("page/booking") {
                if let id = payload.components(separatedBy: "/").last {
                    StateObservable.shared.bookId = id
                }
                
                NotificationCenter.default.post(name: .audienceBookingDetail, object: nil)
            } else if payload.contains("page/meeting") {
                if let id = payload.components(separatedBy: "/").last {
                    StateObservable.shared.meetingId = id
                }
                
                NotificationCenter.default.post(name: .creatorMeetingDetail, object: nil)
            } else if payload.contains("page/home/creator") {
                NotificationCenter.default.post(name: .creatorHome, object: nil)
                //BELUM
            } else if payload.contains("page/payment/success/booking") || payload.contains("page/payment/failed/booking") {
                if let id = payload.components(separatedBy: "/").last {
                    StateObservable.shared.bookId = id
                }
                
                NotificationCenter.default.post(name: .audienceSuccesPayment, object: nil)
            } else if payload.contains("page/profile/audience") {
                NotificationCenter.default.post(name: .audienceProfile, object: nil)
            }
        }
        
        completionHandler()
      }

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
	}

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return AppDelegate.orientationLock
	}
	
	// MARK: UISceneSession Lifecycle
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {

	}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		 The persistent container for the application. This implementation
		 creates and returns a container, having loaded the store for the
		 application to it. This property is optional since there are legitimate
		 error conditions that could cause the creation of the store to fail.
		 */
		let container = NSPersistentContainer(name: "DinotisApp")
		container.loadPersistentStores(completionHandler: { (_, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
}
