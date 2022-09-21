//
//  Sequence+Uniqued.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/03/22.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
	func unique() -> [Iterator.Element] {
		var seen: Set<Iterator.Element> = []
		return filter { seen.insert($0).inserted }
	}
}
