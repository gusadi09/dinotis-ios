//
//  BankWithdraw.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/10/21.
//

import Foundation

class BankWithdrawRepo {
	static let shared = BankWithdrawRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var bankAccount: URL {
		return URL(string: baseUrl + "/bank-accounts")!
	}
	
	func bankAccount(bankAccId: Int) -> URL {
		return URL(string: baseUrl + "/bank-accounts/\(bankAccId)")!
	}
	
	var  withdrawSaldo: URL {
		return URL(string: baseUrl + "/withdraws")!
	}
	
	func withdrawDetail(withdrawId: String) -> URL {
		return URL(string: baseUrl + "/withdraws/\(withdrawId)")!
	}
	
	var historyTransaction: URL {
		return URL(string: baseUrl + "/balances/user/details")!
	}
}
