//
//  TalentWalletViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/02/22.
//

import Foundation

final class TalentWalletViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	init(backToRoot: @escaping (() -> Void), backToHome: @escaping (() -> Void)) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
	}
}
