//
//  SwiftUIView.swift
//
//
//  Created by Gus Adi on 26/01/23.
//

import SwiftUI

public struct DinotisTabView: ViewModifier {
	
	@Binding var selected: TabRoute
	@Binding var isNewAgenda: Bool
	
	public init(selected: Binding<TabRoute>, isNewAgenda: Binding<Bool>) {
		self._selected = selected
		self._isNewAgenda = isNewAgenda
	}
	
	public func body(content: Content) -> some View {
		ZStack {
			content
				.onAppear {
					UITabBar.appearance().backgroundImage = UIImage()
					UITabBar.appearance().shadowImage = UIImage()
					UITabBar.appearance().isTranslucent = true
					UITabBar.appearance()
				}

			VStack {
				Spacer()

				HStack {

					HStack {
						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationExploreWhiteIcon,
								name: "Explore",
								assignedPage: .explore
							),
							selectedPage: $selected,
							isNew: .constant(false)
						)

						Spacer()

						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationSearchWhiteIcon,
								name: "Search",
								assignedPage: .search
							),
							selectedPage: $selected,
							isNew: .constant(false)
						)

						Spacer()

						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationVideoWhiteIcon,
								name: "Agenda",
								assignedPage: .agenda
							),
							selectedPage: $selected,
							isNew: $isNewAgenda
						)

						Spacer()

						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationProfileWhiteIcon,
								name: "Profile",
								assignedPage: .profile
							),
							selectedPage: $selected,
							isNew: .constant(false)
						)
					}
					.padding(.horizontal)
					.padding(.vertical, 10)
					.background(content: {
						Capsule()
							.foregroundColor(.white)
							.shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
					})
					.padding(.horizontal, 15)
				}
			}
			.padding(.bottom)
			.edgesIgnoringSafeArea(.bottom)
		}

	}
}

public extension View {
	func dinotisTabStyle(_ selected: Binding<TabRoute>, isNewAgenda: Binding<Bool>) -> some View {
		return modifier(DinotisTabView(selected: selected, isNewAgenda: isNewAgenda))
	}
}
