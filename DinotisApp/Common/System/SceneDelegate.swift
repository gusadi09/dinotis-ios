//
//  SceneDelegate.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/08/21.
//

import UIKit
import SwiftUI
import TwilioVideo
import DinotisData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	@ObservedObject var state = StateObservable.shared
    
    @State var isOutdated = false
    
    private let versionCheckingUseCase: CheckingVersionUseCase = CheckingVersionDefaultUseCase()
    
    func onCheckingVersion(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Task {
            await checkingVersion(scene, willConnectTo: session, options: connectionOptions)
        }
    }
    
    func checkingVersion(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) async {
        
        let result = await versionCheckingUseCase.execute()
        let isTokenEmpty = self.state.accessToken.isEmpty
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
                
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                    // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
                    // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
                    
                    let contentView = ContentView().environment(\.managedObjectContext, context)
                    
                    // Use a UIHostingController as window root view controller.
                    if let windowScene = scene as? UIWindowScene {
                        let window = UIWindow(windowScene: windowScene)
                        if success.version.orEmpty().compare(appVersion, options: .numeric) == .orderedDescending {
                            window.rootViewController = UIHostingController(rootView: OutdatedVersionView())
                        } else {
                            if !isTokenEmpty &&
                                ((self?.state.isVerified == "Verified") &&
                                 self?.state.userType != 0) {
                                if self?.state.userType == 2 {
                                    let vm = TalentHomeViewModel(backToRoot: {
                                        self?.state.accessToken = ""
                                        self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                    })
                                    window.rootViewController = UIHostingController(rootView: TalentHomeView(homeVM: vm))
                                } else if self?.state.userType == 3 {
                                    let vm = TabViewContainerViewModel(
                                        userHomeVM: UserHomeViewModel(backToRoot: {
                                            self?.state.accessToken = ""
                                            self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                        }),
                                        talentHomeVM: TalentHomeViewModel(backToRoot: {
                                            self?.state.accessToken = ""
                                            self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                        }),
                                        profileVM: ProfileViewModel(backToRoot: {
                                            self?.state.accessToken = ""
                                            self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                        }, backToHome: {}),
                                        searchVM: SearchTalentViewModel(backToRoot: {
                                            self?.state.accessToken = ""
                                            self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                        }, backToHome: {}),
                                        scheduleVM: ScheduleListViewModel(backToRoot: {
                                            self?.state.accessToken = ""
                                            self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                        }, backToHome: {}, currentUserId: ""),
                                        backToRoot: {
                                            self?.state.accessToken = ""
                                            self?.onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
                                        }
                                    )
                                    window.rootViewController = UIHostingController(rootView: TabViewContainer(viewModel: vm))
                                }
                            } else if !isTokenEmpty &&
                                        ((self?.state.isVerified == "VerifiedNoName") &&
                                         self?.state.userType != 0) {
                                window.rootViewController = UIHostingController(rootView: contentView)
                            } else {
                                window.rootViewController = UIHostingController(rootView: contentView)
                            }
                        }
                        self?.window = window
                        if #available(iOS 13.0, *) {
                            self?.window!.overrideUserInterfaceStyle = .light
                        }
                        window.makeKeyAndVisible()
                    }
                }
            }
        case .failure:
            break
        }
    }
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
        onCheckingVersion(scene, willConnectTo: session, options: connectionOptions)
	}
	
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		if let url = URLContexts.first?.url {
			let urlString = url.absoluteString

			if urlString.contains("payment") {
				let component = urlString.components(separatedBy: "/")

				if let id = component.last {
					let secondComponent = id.components(separatedBy: "&")

					if let rawId = secondComponent.first {

						let thirdComponent = rawId.components(separatedBy: "?")

						if let fixedId = thirdComponent.first {
							state.isShowInvoice.toggle()
							state.bookId = fixedId
						}
					}
				}

			} else if urlString.contains("booking") {
				let component = urlString.components(separatedBy: "/")

				if let id = component.last {
					state.isGoToDetailSchedule.toggle()
					state.bookId = id
				}
			}

		}
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}
	
	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
		
		// Save changes in the application's managed object context when the application transitions to the background.
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}

	func windowScene(
		_ windowScene: UIWindowScene,
		didUpdate previousCoordinateSpace: UICoordinateSpace,
		interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
		traitCollection previousTraitCollection: UITraitCollection
	) {
		// So the camera handles orientation changes correctly
		UserInterfaceTracker.sceneInterfaceOrientationDidChange(windowScene)
	}
}
