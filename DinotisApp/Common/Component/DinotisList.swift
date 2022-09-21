//
//  DinotisList.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/09/22.
//

import SwiftUI
import Introspect

struct DinotisList<Content>: View where Content: View {

	private var views: Content
	private var introspectConfig: (UITableView) -> Void

	init(introspectConfig: @escaping (UITableView) -> Void, @ViewBuilder content: () -> Content) {
		self.introspectConfig = introspectConfig
		self.views = content()
	}

    var body: some View {
		if #available(iOS 16.0, *) {
			List {
				views
					.listRowSeparator(.hidden)
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)

		} else {
			List {
				views
			}
			.listStyle(.plain)
			.introspectTableView(customize: { view in
				introspectConfig(view)
			})
		}
    }
}

struct DinotisList_Previews: PreviewProvider {
    static var previews: some View {
		DinotisList(introspectConfig: { _ in

		}) {
			Text("Test")
			Text("Test")
		}
    }
}
