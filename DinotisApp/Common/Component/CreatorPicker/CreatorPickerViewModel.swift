//
//  CreatorPickerViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/04/23.
//

import Foundation
import DinotisData

final class CreatorPickerViewModel: ObservableObject {
    private let getTalentUseCase: GetSearchedTalentUseCase
    
    private var timer: Timer?
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var isLoadingMore = false
    @Published var take = 10
    @Published var search = ""
    @Published var nextCursor: Int? = 0
    @Published var talent = [TalentWithProfessionData]()
    
    init(getTalentUseCase: GetSearchedTalentUseCase = GetSearchedTalentDefaultUseCase()) {
        self.getTalentUseCase = getTalentUseCase
    }
    
    func onStartedLoad(isMore: Bool) {
        DispatchQueue.main.async {[weak self] in
            if isMore {
                self?.isLoadingMore = true
            } else {
                self?.isLoading = true
            }
            
            self?.isError = false
        }
    }
    
    func searchTalent() {
        if let timer = timer {
            timer.invalidate()
        }
        
        take = 10
        
        onStartedLoad(isMore: false)

        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(searchedTalent), userInfo: nil, repeats: false)
    }
    
    @objc func searchedTalent() {
        Task {
            await getTalent(isMore: false)
        }
    }
    
    func getTalent(isMore: Bool) async {
        
        onStartedLoad(isMore: isMore)
        
        let body = TalentsRequest(query: search , skip: take-10, take: take)
        
        let result = await getTalentUseCase.execute(query: body)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
                
                self?.nextCursor = success.nextCursor
                if isMore {
                    self?.talent += success.data ?? []
                } else {
                    self?.talent = success.data ?? []
                }
                
                self?.talent = self?.talent.unique() ?? []
            }
        case .failure(_):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
                
                self?.isError = true
            }
        }
    }
    
    func onGetTalent(isMore: Bool) {
        Task {
            await getTalent(isMore: isMore)
        }
    }
}
