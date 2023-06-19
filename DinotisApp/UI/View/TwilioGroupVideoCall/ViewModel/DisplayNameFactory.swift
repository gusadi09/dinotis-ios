//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

class DisplayNameFactory {
	func makeDisplayName(identity: String, isHost: Bool, isYou: Bool = false) -> String {
		"\(isYou ? "\(LocaleText.you)" : identity)\(isHost ? " (Host)" : "")"
	}
}
