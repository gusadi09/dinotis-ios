//
//  SearchTalentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/03/22.
//

import SwiftUI
import SwiftUINavigation

struct SearchTalentView: View {
	
	@ObservedObject var viewModel: SearchTalentViewModel
	
	var body: some View {
		GeometryReader { geo in
			ZStack {

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.talentProfileDetail,
					destination: {viewModel in
						TalentProfileDetailView(viewModel: viewModel.wrappedValue)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)

				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.bottom)

				ScrollViewReader { scroll in
					VStack(spacing: 0) {
						VStack(spacing: 0) {
							NavigationView(viewModel: viewModel)

							SearchBarView(viewModel: viewModel, scroll: scroll)
								.padding()

							if !viewModel.searchText.isEmpty || !viewModel.categorySelectedName.isEmpty {
								ScrollView(.horizontal, showsIndicators: false) {
									HStack {

										if !viewModel.categorySelectedName.isEmpty {
											ProfessionChips(viewModel: viewModel, title: LocaleText.allInText(by: viewModel.categorySelectedName), id: 0)

											ForEach(viewModel.professionDataByCategory, id: \.id) { item in
												ProfessionChips(viewModel: viewModel, title: item.name, id: item.id)
											}

										}
									}
									.padding(.horizontal)
									.padding(.bottom)
								}
							}
						}
						.background(
							Color.white
								.shadow(color: .dinotisShadow.opacity(0.05), radius: 8, x: 0, y: 15)
						)


						ScrollView(.vertical, showsIndicators: true) {
							LazyVStack {
								if viewModel.isCategoriesShow() {
									CategoriesView(viewModel: viewModel, geo: geo)
								} else {
									SearchResultView(viewModel: viewModel)
								}
							}
						}
					}
				}
			}
		}
		.onAppear {
			viewModel.getCategory()
			viewModel.getProfession()
			
			if viewModel.categorySelectedId != 0 {
				viewModel.getProfessionByCategory()
				viewModel.searchTalent()
				viewModel.getTrendingByCategory()
			}
			
			viewModel.username = nil
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

private extension SearchTalentView {
	struct NavigationView: View {
		
		@ObservedObject var viewModel: SearchTalentViewModel
		
		@Environment(\.presentationMode) var presentationMode
		
		var body: some View {
			VStack(spacing: 0) {
				ZStack {
					HStack {
						Button {
							viewModel.onViewDisappear()
							viewModel.backToHome()
						} label: {
							Image.Dinotis.arrowBackIcon
								.resizable()
								.scaledToFit()
								.frame(height: 15)
						}
						Spacer()
					}
					
					Text(LocaleText.searchInTitle(
						categoryName: viewModel.categorySelectedName,
						categoryId: viewModel.categorySelectedId,
						professionId: viewModel.professionId,
						professionName: viewModel.professionSelect
					))
					.font(.montserratBold(size: 14))
					.foregroundColor(.black)
					
				}
				.padding(.horizontal)
				.padding(.bottom)
				.padding(.top, 10)
				.background(
					Color.white
				)
			}
		}
	}
	
	struct SearchBarView: View {
		
		@ObservedObject var viewModel: SearchTalentViewModel
		var scroll: ScrollViewProxy
		
		var body: some View {
			HStack {
				HStack(spacing: 15) {
					Image.Dinotis.magnifyingIcon
					
					TextField(LocaleText.searchText, text: $viewModel.searchText)
						.font(.montserratRegular(size: 14))
						.disableAutocorrection(true)
						.valueChanged(value: viewModel.searchText) { _ in
							viewModel.takeItem = 30
							viewModel.searchResult = []
							viewModel.startCheckingTimer()
							
							withAnimation {
								scroll.scrollTo(0, anchor: .top)
							}
							
						}
						.valueChanged(value: viewModel.professionId) { _ in
							viewModel.takeItem = 30
							viewModel.searchResult = []
							viewModel.searchTalent()
							viewModel.getTrendingByCategory()
							
							withAnimation {
								scroll.scrollTo(0, anchor: .top)
							}
						}
						.valueChanged(value: viewModel.categorySelectedId) { _ in
							viewModel.takeItem = 30
							viewModel.professionId = 0
							viewModel.searchResult = []
							viewModel.searchTalent()
							viewModel.getTrendingByCategory()
							
							withAnimation {
								scroll.scrollTo(0, anchor: .top)
							}
						}
					
					Spacer()
				}
				.padding()
				.background(Color.backgroundProfile)
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.gray.opacity(0.3), lineWidth: 1.0)
				)
				
				if !viewModel.searchText.isEmpty || !viewModel.categorySelectedName.isEmpty {
					Button {
						viewModel.onCancelSearch()
					} label: {
						Text(LocaleText.cancelText)
							.font(.montserratSemiBold(size: 14))
							.foregroundColor(.primaryViolet)
					}
				}
			}
		}
	}
	
	struct ProfessionChips: View {
		
		@ObservedObject var viewModel: SearchTalentViewModel
		
		var title: String
		var id: Int
		
		var body: some View {
			Button(action: {
				viewModel.professionSelect = title
				viewModel.professionId = id
			}, label: {
				Text(title)
					.font(Font.custom(FontManager.Montserrat.regular, size: 14))
					.foregroundColor(.black)
					.padding(.horizontal)
					.padding(.vertical, 10)
					.background(viewModel.professionId == id ? .secondaryViolet : Color.gray.opacity(0.2))
					.cornerRadius(8)
			})
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(viewModel.professionId == id ? .primaryViolet : Color.gray.opacity(0.5), lineWidth: 1.0)
			)
			.padding(.top, 5)
		}
	}
	
	struct CategoriesView: View {
		
		@ObservedObject var viewModel: SearchTalentViewModel
		let geo: GeometryProxy
		
		var body: some View {
			Group {
				HStack {
					Text(LocaleText.searchByCategory)
						.font(.montserratBold(size: 14))
						.foregroundColor(.black)
					
					Spacer()
				}
				.padding()
				
				UIGrid(columns: 4, list: viewModel.categoryData) { items in
					Button(action: {
						viewModel.categorySelectedName = items.name.orEmpty()
						viewModel.categorySelectedId = items.id.orZero()
						viewModel.getProfessionByCategory()
					}, label: {
						Chips(titleKey: items.name.orEmpty(), geo: geo)
							.foregroundColor(.white)
							.cornerRadius(12)
					})
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
	
	struct SearchResultView: View {
		
		@ObservedObject var viewModel: SearchTalentViewModel
		
		var body: some View {
			Group {
				VStack {
					if viewModel.searchText.isEmpty && viewModel.categorySelectedId != 0 {
						if !viewModel.trendingResult.isEmpty {
							VStack {
								HStack {
									Text(LocaleText.moreCrowdedInCategory(
										categoryName: viewModel.categorySelectedName,
										professionId: viewModel.professionId,
										professionName: viewModel.professionSelect
									))
									.font(.montserratBold(size: 14))
									.foregroundColor(.black)
									.valueChanged(value: viewModel.takeItem) { _ in
										if viewModel.nextCursor != 0 {
											viewModel.searchTalent()
										}
									}
									
									Spacer()
								}
								.padding()
								
								ScrollView(.horizontal, showsIndicators: false) {
									HStack {
										ForEach(viewModel.trendingResult.indices, id: \.self) { items in
											TalentSearchCard(
												onTapSee: {
													viewModel.username = viewModel.trendingResult[items].username.orEmpty()
													viewModel.routeToTalentProfile()
												}, user: .constant(viewModel.trendingResult[items])
											)
										}
									}
									.padding(.horizontal)
								}
							}
						}
					}
					
					VStack {
						HStack {
							Text(LocaleText.searchResultText())
								.font(.montserratBold(size: 14))
								.foregroundColor(.black)
								.valueChanged(value: viewModel.takeItem) { _ in
									viewModel.searchTalent()
								}
							
							Spacer()
						}
						.padding()
						.id(0)
						
						if viewModel.searchResult.isEmpty && !viewModel.isSearchLoading {
							EmptySearch()
								.padding(.bottom)
						} else {
							LazyVStack(spacing: 10) {
								ForEach(viewModel.searchResult, id: \.id) { items in
									LazyVStack {
										if items.id == (viewModel.searchResult.last?.id).orEmpty() {
											Button {
												viewModel.username = items.username.orEmpty()
												viewModel.routeToTalentProfile()
											} label: {
												TalentSearchVerticalCardView(
													user: items,
													isLast: true,
													take: $viewModel.takeItem
												)
											}
										} else {
											Button {
												viewModel.username = items.username.orEmpty()
												viewModel.routeToTalentProfile()
											} label: {
												TalentSearchVerticalCardView(
													user: items,
													isLast: false,
													take: $viewModel.takeItem
												)
											}
										}
									}
								}
							}
						}
						
						HStack {
							Spacer()
							
							ActivityIndicator(isAnimating: $viewModel.isSearchLoading, color: .black, style: .medium)
								.padding()
							
							Spacer()
						}
						.isHidden(!viewModel.isSearchLoading, remove: !viewModel.isSearchLoading)
					}
					.padding(.bottom)
				}
			}
		}
	}
}

struct SearchTalentView_Previews: PreviewProvider {
	static var previews: some View {
		SearchTalentView(viewModel: SearchTalentViewModel(backToRoot: {}, backToHome: {}))
	}
}
