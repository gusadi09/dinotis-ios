//
//  CreateTalentRateCardFormViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/10/22.
//

import Foundation
import Combine
import OneSignal
import DinotisData
import DinotisDesignSystem

final class CreateTalentRateCardFormViewModel: ObservableObject {

	private let createRateCardUseCase: CreateRateCardUseCase
	private let editRateCardUseCase: EditRateCardUseCase
	private let detailRateCardUseCase: DetailRateCardUseCase
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared

	@Published var isEdit: Bool
	@Published var rateCardId: String
    @Published var title = ""
    @Published var desc = ""
    @Published var price = "0"
    @Published var duration = "0"

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()

	@Published var isRefreshFailed = false

	@Published var titleError: String?
	@Published var descError: String?
	@Published var durationError: String?

	@Published var createdData: RateCardResponse?
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?
    
    init(
		isEdit: Bool,
		rateCardId: String,
		backToHome: @escaping (() -> Void),
		createRateCardUseCase: CreateRateCardUseCase = CreateRateCardDefaultUseCase(),
		editRateCardUseCase: EditRateCardUseCase = EditRateCardDefaultUseCase(),
		detailRateCardUseCase: DetailRateCardUseCase = DetailRateCardDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.isEdit = isEdit
		self.rateCardId = rateCardId
        self.backToHome = backToHome
		self.createRateCardUseCase = createRateCardUseCase
		self.editRateCardUseCase = editRateCardUseCase
		self.detailRateCardUseCase = detailRateCardUseCase
		self.authRepository = authRepository
    }

    func isDisabled() -> Bool {
		title.isEmpty || desc.isEmpty || duration.isEmpty || duration == "0"
    }

	func routeToRoot() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
	}

	func headerTitle() -> String {
		isEdit ? LocaleText.editRateCardText : LocaleText.createRateCard
	}

	func buttonSubmitText() -> String {
		isEdit ? LocaleText.saveText : LocaleText.createRateCard
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

	func handleDefaultErrorCreate(error: Error) {
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
              self?.routeToRoot()
            }
          )
          self?.isShowAlert = true
				} else if error.statusCode.orZero() == 422 {
					if let titleError = error.fields?.first(where: { $0.name == "title"}) {
						self?.titleError = titleError.error
					}

					if let descError = error.fields?.first(where: { $0.name == "description"}) {
						self?.descError = descError.error
					}

					if let durationError = error.fields?.first(where: { $0.name == "duration"}) {
						self?.durationError = durationError.error
					}
				} else {
					self?.error = error.message.orEmpty()
					self?.isError = true
          self?.alert.isError = true
          self?.alert.message = error.message.orEmpty()
          self?.isShowAlert = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
        self?.alert.isError = true
        self?.alert.message = error.localizedDescription
        self?.isShowAlert = true
			}

		}
	}

  func createRateCard(dismiss: @escaping () -> Void) async {
		onStartRequest()

		let body = CreateRateCardRequest(title: title, description: desc, duration: Int(duration).orZero(), price: Int(price).orZero())

		let result = await createRateCardUseCase.execute(with: body)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false
				self?.success = true

				self?.createdData = success
        self?.isError = false
        self?.alert.title = LocaleText.successTitle
        self?.alert.message = LocaleText.successCreateRateCardText
        self?.alert.primaryButton = .init(
          text: LocalizableText.okText,
          action: dismiss
        )
        self?.isShowAlert = true
			}
		case .failure(let failure):
			handleDefaultErrorCreate(error: failure)
		}
	}

	func handleDefaultErrorEdit(error: Error) {
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
              self?.routeToRoot()
            }
          )
          self?.isShowAlert = true
				} else if error.statusCode.orZero() == 422 {
					if let titleError = error.fields?.first(where: { $0.name == "title"}) {
						self?.titleError = titleError.error
					}

					if let descError = error.fields?.first(where: { $0.name == "description"}) {
						self?.descError = descError.error
					}

					if let durationError = error.fields?.first(where: { $0.name == "duration"}) {
						self?.durationError = durationError.error
					}

				} else {
					self?.error = error.message.orEmpty()
					self?.isError = true
          self?.alert.isError = true
          self?.alert.message = error.message.orEmpty()
          self?.isShowAlert = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
        self?.alert.isError = true
        self?.alert.message = error.localizedDescription
        self?.isShowAlert = true
			}

		}
	}

  func editRateCard(dismiss: @escaping () -> Void) async {
		onStartRequest()

		let body = CreateRateCardRequest(title: title, description: desc, duration: Int(duration).orZero(), price: Int(price).orZero())

		let result = await editRateCardUseCase.execute(for: rateCardId, with: body)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false
				self?.success = true
				self?.createdData = success
        self?.alert.isError = false
        self?.alert.message = LocaleText.successUpdateRateCardText
        self?.alert.title = LocaleText.successTitle
        self?.alert.primaryButton = .init(
          text: LocalizableText.okText,
          action: dismiss
        )
        self?.isShowAlert = true
			}
		case .failure(let failure):
			handleDefaultErrorEdit(error: failure)
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
              self?.routeToRoot()
            }
          )
          self?.isShowAlert = true
				} else {
					self?.error = error.message.orEmpty()
					self?.isError = true
          self?.alert.isError = true
          self?.alert.message = error.message.orEmpty()
          self?.isShowAlert = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
        self?.alert.isError = true
        self?.alert.message = error.localizedDescription
        self?.isShowAlert = true
			}

		}
	}

	func getDetailRateCard() async {
		onStartRequest()

		let result = await detailRateCardUseCase.execute(for: rateCardId)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false

				self?.title = success.title.orEmpty()
				self?.desc = success.description.orEmpty()
				self?.price = success.price.orEmpty()
				self?.duration = success.duration.orZero().numberString
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func onAppear() {
		Task {
			if self.isEdit {
				await getDetailRateCard()
			}
		}
	}

  func submitForm(dismiss: @escaping () -> Void) {
		Task {
			if isEdit {
				await editRateCard(dismiss: dismiss)
			} else {
				await createRateCard(dismiss: dismiss)
			}
		}
	}
}
