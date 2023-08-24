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
    @Binding var isShowTooltip: Bool
	
	public init(
        selected: Binding<TabRoute>,
        isNewAgenda: Binding<Bool>,
        isShowTooltip: Binding<Bool>
    ) {
		self._selected = selected
		self._isNewAgenda = isNewAgenda
        self._isShowTooltip = isShowTooltip
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
                                name: LocalizableText.tabExplore,
								assignedPage: .explore
							),
							selectedPage: $selected,
							isNew: .constant(false)
						)

						Spacer()

						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationSearchWhiteIcon,
                                name: LocalizableText.tabSearch,
								assignedPage: .search
							),
							selectedPage: $selected,
							isNew: .constant(false)
						)

						Spacer()
                        
						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationVideoWhiteIcon,
                                name: LocalizableText.tabAgenda,
								assignedPage: .agenda
							),
							selectedPage: $selected,
							isNew: $isNewAgenda,
                            isShowTooltip: $isShowTooltip
						)
                        .dinotisTooltip($isShowTooltip, id: TabBounce.agenda.rawValue, width: 200, height: 56) {
                            Text(LocalizableText.tooltipAgenda)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }

						Spacer()

						TabIcon(
							tabIcon: TabIconModel(
								icon: .bottomNavigationProfileWhiteIcon,
                                name: LocalizableText.tabProfile,
								assignedPage: .profile
							),
							selectedPage: $selected,
							isNew: .constant(false)
						)
					}
					.padding(.horizontal)
					.padding(.vertical, 10)
                    .overlay {
                        Capsule()
                            .onTapGesture {
                                isShowTooltip = false
                            }
                            .foregroundColor(.black.opacity(0.5))
                            .isHidden(!isShowTooltip, remove: !isShowTooltip)
                    }
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
        .overlayPreferenceValue(BoundsPreference.self, alignment: .top, { value in
            if let preference = value.first(where: { item in
                item.key == TabBounce.agenda.rawValue
            }), isShowTooltip {
                GeometryReader { proxy in
                    let rect = proxy[preference.value]
                    
                    TabIcon(
                        tabIcon: TabIconModel(
                            icon: .bottomNavigationVideoWhiteIcon,
                            name: LocalizableText.tabAgenda,
                            assignedPage: .agenda
                        ),
                        selectedPage: $selected,
                        isNew: $isNewAgenda,
                        isShowTooltip: $isShowTooltip
                    )
                    .dinotisTooltip($isShowTooltip, id: TabBounce.agenda.rawValue, width: 200, height: 56) {
                        Text(LocalizableText.tooltipAgenda)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                }
            }
        })
	}
}

public extension View {
	func dinotisTabStyle(_ selected: Binding<TabRoute>, isNewAgenda: Binding<Bool>, isShowTooltip: Binding<Bool>) -> some View {
        return modifier(DinotisTabView(selected: selected, isNewAgenda: isNewAgenda, isShowTooltip: isShowTooltip))
	}
}

struct DummyPreview: View {
    @State var selected: TabRoute = .explore
    @State var isShowTooltip = false
    
    var body: some View {
        TabView(selection: $selected) {
            ZStack {
                Text("Explore")
                    .onTapGesture {
                        isShowTooltip.toggle()
                    }
                
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .isHidden(!isShowTooltip)
            }
            .tag(TabRoute.explore)
            
            Text("Search")
                .tag(TabRoute.search)
            
            Text("Agenda")
                .onAppear {
                    isShowTooltip.toggle()
                }
                .tag(TabRoute.agenda)
            
            Text("Profile")
                .tag(TabRoute.profile)
        }
        .dinotisTabStyle($selected, isNewAgenda: .constant(false), isShowTooltip: $isShowTooltip)
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        DummyPreview()
    }
}
