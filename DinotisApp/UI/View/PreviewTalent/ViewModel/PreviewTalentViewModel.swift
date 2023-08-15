//
//  PreviewTalentViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/04/22.
//

import Foundation
import Combine
import UIKit
import DinotisData

final class PreviewTalentViewModel: ObservableObject {

	private var cancellables = Set<AnyCancellable>()
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	var stateObservable = StateObservable.shared
	private let getUserUseCase: GetUserUseCase

	@Published var photoProfile: String?
	@Published var profileBanner = [HighlightData]()
	@Published var profileBannerContent = [ProfileBannerImage]()

	@Published var isRefreshFailed = false

	@Published var nameOfUser: String?
	@Published var userData: UserResponse?

	@Published var showingPasswordAlert = false

	@Published var route: HomeRouting?

	@Published var showMenuCard = false

	@Published var isError: Bool = false
	@Published var error: String?
	@Published var success: Bool = false

	@Published var isLoading = false

	init(
		getUserUseCase: GetUserUseCase = GetUserDefaultUseCase()
	) {
		self.getUserUseCase = getUserUseCase
	}

	func onStartedFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.error = nil
			self?.success = false
		}
	}

	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }

        }
    }

    func getUsers() async {
        onStartedFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.userData = success
                self?.nameOfUser = success.name
                self?.photoProfile = success.profilePhoto
                
                self?.profileBanner = success.userHighlights ?? []
                var temp = [ProfileBannerImage]()
                
                if !(success.userHighlights ?? []).isEmpty {
                    for item in success.userHighlights ?? [] {
                        temp.append(
                            ProfileBannerImage(
                                content: item
                            )
                        )
                    }
                    
                    self?.profileBannerContent = temp
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

	@objc func onScreenAppear() {
        Task {
            await getUsers()
        }
	}

	func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			self,
			action: #selector(self.onValueChangedAction),
			for: .valueChanged
		)
		scrollView.refreshControl = refreshControl
		self.onValueChanged = onValueChanged
	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			await onScreenAppear()
			self.onValueChanged?(sender)
		}
	}
}
