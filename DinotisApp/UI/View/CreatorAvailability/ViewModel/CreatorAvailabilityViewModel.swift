//
//  CreatorAvailabilityViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 26/10/23.
//

import Foundation
import DinotisDesignSystem

enum SubscriptionType {
    case monthly
    case free
}

final class CreatorAvailabilityViewModel: ObservableObject {
    
    @Published var route: HomeRouting?
    
    @Published var isShowSubscriptionSheet = false
    @Published var hasSetSubscription = false
    
    @Published var subscriptionType: SubscriptionType?
    @Published var subscriptionAmount = ""
    
    var backToHome: () -> Void
    
    var subscriptionTypeText: String {
        switch subscriptionType {
        case .monthly:
            LocalizableText.subscriptionPaidMonthly
        case .free:
            LocalizableText.subscriptionPaidFree
        case nil:
            LocalizableText.profileSelectSubscriptionTypePlaceholder
        }
    }
    
    init(backToHome: @escaping () -> Void) {
        self.backToHome = backToHome
    }
    
    func checkZeroAtFirst(_ value: String) {
        if value.starts(with: "0") {
            subscriptionAmount = String(value.dropFirst())
        }
    }
}
