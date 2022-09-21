//
//  UserHomeView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/04/22.
//

import SwiftUI
import SwiftUINavigation
import SDWebImageSwiftUI

extension UserHomeView {
	
	struct NavigationHelper: View {
		
		@ObservedObject var homeVM: UserHomeViewModel
		
		var body: some View {
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.talentProfileDetail,
				destination: { viewModel in
					TalentProfileDetailView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)

			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.coinHistory,
				destination: { viewModel in
					CoinHistoryView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.loginResetPassword,
				destination: { viewModel in
					LoginPasswordResetView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.searchTalent,
				destination: {viewModel in
					SearchTalentView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $homeVM.route,
				case: /HomeRouting.scheduleList,
				destination: {viewModel in
					ScheduleListView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
		}
	}
	
	struct HeaderView: View {
		
		@ObservedObject var homeVM: UserHomeViewModel
		
		var body: some View {
			VStack(spacing: 25) {
				
				HStack {
					Button(action: {
						homeVM.routeToProfile()
					}, label: {
						HStack(spacing: 15) {
							ProfileImageContainer(
								profilePhoto: $homeVM.photoProfile,
								name: $homeVM.nameOfUser,
								width: 55,
								height: 55
							)
							
							VStack(alignment: .leading, spacing: 15) {
								Text(LocaleText.helloText)
									.font(.montserratRegular(size: 14))
									.foregroundColor(.black)
								
								Text(homeVM.nameOfUser.orEmpty())
									.font(.montserratBold(size: 14))
									.foregroundColor(.black)
							}
						}
						
					})
					
					NavigationLink(
						unwrapping: $homeVM.route,
						case: /HomeRouting.userProfile) { viewModel in
							UserProfileView(viewModel: viewModel.wrappedValue)
						} onNavigate: { _ in
							
						} label: {
							EmptyView()
						}
					
					Spacer()
					
				}
				
				Button {
					homeVM.routeToSearch()
				} label: {
					HStack(spacing: 15) {
						Image.Dinotis.magnifyingIcon
						
						Text(LocaleText.searchText)
							.font(.montserratRegular(size: 14))
							.foregroundColor(.gray)
						
						Spacer()
					}
					.padding()
					.background(Color.backgroundProfile)
					.cornerRadius(8)
					.overlay(
						RoundedRectangle(cornerRadius: 8)
							.stroke(Color.gray.opacity(0.3), lineWidth: 1.0)
					)
				}
			}
			.padding()
			.background(
				Color.white.shadow(
					color: Color.dinotisShadow.opacity(0.06),
					radius: 10, x: 0.0, y: 12
				)
			)
		}
	}
	
	struct CategoryList: View {

		var geo: GeometryProxy
		@ObservedObject var homeVM: UserHomeViewModel
		
		var body: some View {
			HStack {
				ForEach((homeVM.categoryData?.data ?? []).prefix(4), id: \.id) { item in
					Button {
						homeVM.selectedCategory = item.name.orEmpty()
						homeVM.selectedCategoryId = item.id.orZero()
						homeVM.routeToSearch()
					} label: {
						VStack(spacing: 10) {
							WebImage(url: item.icon?.toURL())
								.resizable()
								.indicator(.activity)
								.transition(.fade(duration: 0.5))
								.scaledToFit()
								.frame(width: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.width/8.5 : geo.size.width/5.5)
							
							Text(item.name.orEmpty())
								.font(.montserratMedium(size: 11))
								.foregroundColor(.black)
						}
					}
					
					if item.id != homeVM.categoryData?.data?.last?.id {
						Spacer()
					}
				}
			}
			.padding()
		}
	}
	
	struct VideoCallScheduleSection: View {
		
		@ObservedObject var homeVM: UserHomeViewModel
		var geo: GeometryProxy
		
		var body: some View {
			VStack {
				HStack {
					Text(LocaleText.videoCallSchedule)
						.font(.montserratBold(size: 14))
					
					Spacer()
				}
				.padding(.horizontal)
				
				Button {
					homeVM.routeToScheduleList()
				} label: {
					HStack {
						Image.Dinotis.sheduleIllustrate
						
						VStack(alignment: .leading) {
							Text(LocaleText.checkSchedule)
								.font(.montserratBold(size: 12))
							
							Text(LocaleText.checkScheduleSubtitle)
								.font(.montserratRegular(size: 12))
							
						}
						.foregroundColor(.black)
						.multilineTextAlignment(.leading)
						.padding(.leading, 15)
						
						Spacer()
						
						Image.Dinotis.buttonScheduleChevronIcon
					}
					.padding(.horizontal)
					.background(
						Image.Dinotis.scheduleButtonBackground
							.resizable()
							.frame(width: geo.size.width - 40, height: 123)
					)
					.frame(width: geo.size.width - 40, height: 123)
				}
				
			}
		}
	}
	
	struct EmptySearch: View {
		var body: some View {
			HStack {
				Spacer()
				VStack(spacing: 10) {
					Image.Dinotis.searchNotFoundImage
						.resizable()
						.scaledToFit()
						.frame(
							height: 137
						)
					
					Text(NSLocalizedString("no_search_label", comment: ""))
						.font(Font.custom(FontManager.Montserrat.bold, size: 14))
						.foregroundColor(.black)
					
					Text(NSLocalizedString("another_keyword_label", comment: ""))
						.font(Font.custom(FontManager.Montserrat.regular, size: 12))
						.multilineTextAlignment(.center)
						.foregroundColor(.black)
				}
				.padding()
				
				Spacer()
			}
			.background(Color.white)
			.cornerRadius(12)
			.padding(.horizontal)
			.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0.0, y: 0.0)
			
		}
	}
	
	struct ProfessionButton: View {
		private let profession: ProfessionProfession
		@Binding private var selectedValue: Int
		private let action: (() -> Void)
		
		init(profession: ProfessionProfession, selectedValue: Binding<Int>, action: @escaping (() -> Void)) {
			self.profession = profession
			self._selectedValue = selectedValue
			self.action = action
		}
		
		var body: some View {
			Button {
				action()
			} label: {
				Text(profession.name)
					.font(.montserratRegular(size: 14))
					.foregroundColor(.black)
					.padding(10)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(selectedValue == profession.id ? .secondaryViolet : Color(.systemGray6))
					)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(selectedValue == profession.id ? Color.primaryViolet : Color(.systemGray5), lineWidth: 1)
					)
			}
		}
	}
}
