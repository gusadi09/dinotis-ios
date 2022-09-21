//
//  PanicReport.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation

struct ReportReasonData: Codable, Equatable {
	let id: Int?
	let name: String?

	static func == (lhs: ReportReasonData, rhs: ReportReasonData) -> Bool {
		return lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

typealias ReportReasonResponse = [ReportReasonData]

struct ReportParams: Codable {
	var identity: String
	var reasons: String
	var notes: String
	var room: String
	var userId: String
	var meetingId: String
}

struct ReportResponse: Codable {
	let userId: String?
}
