//
//  TalentCreateBundlingViewModel.swift
//  DinotisApp
//
//  Created by Garry on 26/09/22.
//

import Foundation
import Combine
import UIKit
import DinotisData

final class TalentCreateBundlingViewModel: ObservableObject {
    
    var backToHome: () -> Void
    var backToBundlingList: () -> Void
    
    @Published var route: HomeRouting?

	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    private let bundlingRepository: BundlingRepository
    private let authRepository: AuthenticationRepository

    private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
	private let bundleId: String

	@Published var isEdit: Bool
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var error: String?
    @Published var isRefreshFailed = false
    
    @Published var allSelected = false
    
    @Published var meetingList = [Meeting]()
    @Published var meetingIdArray = [String]()
    
    init(
		bundleId: String = "",
		isEdit: Bool,
        backToHome: @escaping (() -> Void),
        backToBundlingList: @escaping (() -> Void),
        bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
		self.bundleId = bundleId
		self.isEdit = isEdit
        self.backToHome = backToHome
        self.backToBundlingList = backToBundlingList
        self.bundlingRepository = bundlingRepository
        self.authRepository = authRepository
    }
    
    func onStartFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.isRefreshFailed = false
        }
    }
    
    func getAvailableMeeting() {
        onStartFetch()
        
        bundlingRepository.provideGetAvailableMeeting()
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        if error.statusCode.orZero() == 401 {
                            
                        } else {
                            self?.isLoading = false
                            self?.isError = true

                            self?.error = error.message.orEmpty()
                        }
                    }
                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                    }
                }
            } receiveValue: { value in
                self.meetingList = value.data ?? []
            }
            .store(in: &cancellables)

    }

	func getAvailableMeetingForEdit() {
		onStartFetch()

		bundlingRepository.provideGetAvailableMeetingForEdit(with: bundleId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						if error.statusCode.orZero() == 401 {
							
						} else {
							self?.isLoading = false
							self?.isError = true

							self?.error = error.message.orEmpty()
						}
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.meetingList = value.data ?? []
				print(self.meetingList)
			}
			.store(in: &cancellables)

	}
    
    func addMeeting(id: String) {
        if meetingIdArray.contains(where: {
            $0 == id
        }) {
            guard let index = meetingIdArray.firstIndex(of: id) else { return }
            meetingIdArray.remove(at: index)
        } else {
            meetingIdArray.append(id)
        }
    }
    
    func selectAllSession() {
        if !allSelected {
            meetingIdArray.removeAll()
        } else {
            meetingIdArray = meetingList.map({
                $0.id.orEmpty()
            })
        }
    }
    
    func isAllSelectedManually() -> Bool {
        meetingIdArray.count == meetingList.count
    }
    
    func routeToBundlingForm() {
		let viewModel = BundlingFormViewModel(meetingIdArray: self.meetingIdArray, isEdit: false, backToHome: self.backToHome, backToBundlingList: self.backToBundlingList)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bundlingForm(viewModel: viewModel)
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
}
