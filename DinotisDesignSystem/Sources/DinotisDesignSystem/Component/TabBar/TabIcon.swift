//
//  File.swift
//  
//
//  Created by Gus Adi on 26/01/23.
//

import SwiftUI

public struct TabIcon: View {
	let tabIcon: TabIconModel
	@Binding var selectedPage: TabRoute
	@Binding var isNew: Bool
    @Binding var isShowTooltip: Bool

    public init(tabIcon: TabIconModel, selectedPage: Binding<TabRoute>, isNew: Binding<Bool>, isShowTooltip: Binding<Bool> = .constant(false)) {
		self.tabIcon = tabIcon
		self._selectedPage = selectedPage
		self._isNew = isNew
        self._isShowTooltip = isShowTooltip
	}

	public var body: some View {
		HStack {

			ZStack(alignment: .topTrailing) {
				tabIcon.icon
					.renderingMode(.template)
					.resizable()
					.scaledToFit()
					.frame(height: 22)
					.foregroundColor(tabIcon.assignedPage == selectedPage ? .white : .DinotisDefault.primary)

				if isNew {
					Circle()
						.foregroundColor(.red)
						.scaledToFit()
						.frame(height: 8)
				}
			}

			if tabIcon.assignedPage == selectedPage {
				Text(tabIcon.name)
					.font(.robotoMedium(size: 12))
					.foregroundColor(tabIcon.assignedPage == selectedPage ? .white : .DinotisDefault.primary)
			}
		}
		.padding()
        .frame(maxWidth: isShowTooltip ? 90 : nil)
		.background(
			Capsule()
				.foregroundColor(
					tabIcon.assignedPage == selectedPage ? .DinotisDefault.primary : .white
				)
		)
		.onTapGesture {
			withAnimation(.spring()) {
				selectedPage = tabIcon.assignedPage
			}
		}
	}
}

struct TabIcon_Previews: PreviewProvider {

	static var previews: some View {
        ZStack {
            Color.black.opacity(0.5)
            
            TabIcon(
                tabIcon: TabIconModel(
                    icon: .bottomNavigationVideoWhiteIcon,
                    name: "Explore",
                    assignedPage: .explore
                ),
                selectedPage: .constant(.agenda),
                isNew: .constant(true),
                isShowTooltip: .constant(true)
            )
        }
	}
}
