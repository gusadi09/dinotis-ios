//
//  FollowedCreatorViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation
import UIKit
import SwiftUI
import DinotisDesignSystem
import Combine
import DinotisData

final class FollowedCreatorViewModel: ObservableObject {

	private let followedCreatorUseCase: FollowedCreatorUseCase
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
	private var cancellables = Set<AnyCancellable>()

	var backToRoot: () -> Void
	var backToHome: () -> Void

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var isRefreshFailed = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()

	@Published var route: HomeRouting?

	@Published var query = GeneralParameterRequest(skip: 0, take: 15)

	@Published var talentData = [TalentData]()

	init(
		followedCreatorUseCase: FollowedCreatorUseCase = FollowedCreatorDefaultUseCase(),
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping () -> Void
	) {
		self.followedCreatorUseCase = followedCreatorUseCase
		self.backToRoot = backToRoot
		self.backToHome = backToHome
	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func convertToStringProfession(_ professions: [String]?) -> String {
		(professions ?? []).joined(separator: ", ")
	}

	func convertToCardModel(with data: TalentData) -> CreatorCardModel {
		return CreatorCardModel(
			name: data.name.orEmpty(),
			isVerified: data.isVerified ?? false,
			professions: convertToStringProfession(data.stringProfessions),
			photo: data.profilePhoto.orEmpty()
		)
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
			self?.isRefreshFailed = false
      self?.isShowAlert = false
      self?.alert = .init(
        isError: false,
        title: LocalizableText.attentionText,
        message: "",
        primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
        secondaryButton: nil
      )
		}

	}

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false

			if let error = error as? ErrorResponse {

				if error.statusCode.orZero() == 401 {
					self?.error = error.message.orEmpty()
					self?.isRefreshFailed.toggle()
          self?.alert.isError = true
          self?.alert.message = LocalizableText.alertSessionExpired
          self?.alert.primaryButton = .init(
            text: LocalizableText.okText,
            action: {
              self?.backToRoot()
            }
          )
          self?.isShowAlert = true
				} else {
					self?.error = error.message.orEmpty()
					self?.isError = true
          self?.alert.message = error.message.orEmpty()
          self?.alert.isError = true
          self?.isShowAlert = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
        self?.alert.message = error.localizedDescription
        self?.alert.isError = true
        self?.isShowAlert = true
			}

		}
	}

	func getFollowedCreator() async {
		onStartRequest()

		let result = await followedCreatorUseCase.execute(with: query)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false

				withAnimation {
					self?.talentData += success.data ?? []
					self?.talentData = (self?.talentData ?? []).unique()

					if success.nextCursor == nil {
						self?.query.skip = 0
						self?.query.take = 15
					}
				}
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
		DispatchQueue.main.async {
			let refreshControl = UIRefreshControl()
			refreshControl.addTarget(
				self,
				action: #selector(self.onValueChangedAction),
				for: .valueChanged
			)
			scrollView.refreshControl = refreshControl
			self.onValueChanged = onValueChanged
		}

	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			self.onValueChanged?(sender)
		}
	}

	func routeToRoot() {
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		backToRoot()
	}

	func onRefresh() async {
		await getFollowedCreator()
	}

	func routeToTalentDetail(username: String) {
		let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, username: username)

		DispatchQueue.main.async { [weak self] in
			self?.route = .talentProfileDetail(viewModel: viewModel)
		}
	}
}
