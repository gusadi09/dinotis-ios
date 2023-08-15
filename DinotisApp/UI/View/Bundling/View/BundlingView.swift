//
//  BundlingView.swift
//  DinotisApp
//
//  Created by Garry on 22/09/22.
//

import SwiftUI
import SwiftUINavigation
import DinotisDesignSystem

struct BundlingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: BundlingViewModel
    
    var body: some View {
        GeometryReader { geo in
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.createBundling,
                destination: { viewModel in
					TalentCreateBundlingView(viewModel: viewModel.wrappedValue, meetingArray: .constant([]))
                },
                onNavigate: { _ in },
                label: {
                    EmptyView()
                }
            )

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.bundlingForm,
				destination: { viewModel in
					BundlingFormView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.bundlingDetail,
                destination: { viewModel in
                    BundlingDetailView(viewModel: viewModel.wrappedValue, isPreview: false, tabValue: .constant(.agenda))
                },
                onNavigate: { _ in },
                label: {
                    EmptyView()
                }
            )
            
            ZStack(alignment: .bottomTrailing) {
                Color.homeBgColor.ignoresSafeArea()
                    .alert(isPresented: $viewModel.isError) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(viewModel.error.orEmpty()),
                            dismissButton: .default(Text(LocaleText.okText))
                        )
                    }
                
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        HeaderView()

						HStack {
							Image(systemName: "slider.horizontal.3")
								.resizable()
								.scaledToFit()
								.frame(height: 15)
								.foregroundColor(.DinotisDefault.primary)

							Text(LocaleText.generalFilterSchedule)
								.font(.robotoMedium(size: 12))
								.foregroundColor(.DinotisDefault.primary)

							Spacer()

							Menu {
								Picker(selection: $viewModel.filterSelection) {
									ForEach(viewModel.filterList, id: \.id) { item in
										Text(item.label.orEmpty())
											.tag(item.label.orEmpty())
									}
								} label: {
									EmptyView()
								}
							} label: {
								HStack(spacing: 10) {
									if viewModel.filterSelection.isEmpty {
										ProgressView()
											.progressViewStyle(.circular)
											.padding(.horizontal, 60)
									} else {
										Text(viewModel.filterSelection)
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
									}

									Image(systemName: "chevron.down")
										.resizable()
										.scaledToFit()
										.frame(height: 5)
										.foregroundColor(.black)
								}
								.padding(.horizontal, 15)
								.padding(.vertical, 10)
								.background(
									RoundedRectangle(cornerRadius: 10)
										.foregroundColor(.secondaryViolet)
								)
								.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.DinotisDefault.primary, lineWidth: 1))
							}
						}
						.buttonStyle(.plain)
						.padding(.horizontal)
						.padding(.bottom, 10)
						.onChange(of: viewModel.filterSelection) { newValue in
							viewModel.changeFilter(filter: newValue)
						}
                        
						Group {
							DinotisList {
								viewModel.getBundlingList()
							} introspectConfig: { view in
								view.separatorStyle = .none
								view.indicatorStyle = .white
								view.sectionHeaderHeight = -10
								view.showsVerticalScrollIndicator = false
								viewModel.use(for: view) { refresh in
									viewModel.getBundlingList()
									refresh.endRefreshing()
								}
							} content: {

								if viewModel.bundlingListData.unique().isEmpty {
									VStack(spacing: 20) {

										Image.Dinotis.emptyScheduleImage
											.resizable()
											.scaledToFit()
											.frame(height: 137)

										VStack(spacing: 10) {
											Text(LocaleText.emptyBundlingTitle)
												.font(.robotoBold(size: 14))
												.multilineTextAlignment(.center)
												.foregroundColor(.black)

											Text(LocaleText.emptyBundlingSubtitle)
												.font(.robotoRegular(size: 12))
												.multilineTextAlignment(.center)
												.foregroundColor(.black)
										}

										Button {
											viewModel.routeToCreateBundling()
										} label: {
											HStack {
												Spacer()

												Text(LocaleText.createBundleText)
													.font(.robotoMedium(size: 12))
													.foregroundColor(.white)

												Spacer()
											}
											.padding()
											.background(
												RoundedRectangle(cornerRadius: 10)
													.foregroundColor(.DinotisDefault.primary)
											)
										}

									}
									.padding(30)
									.background(
										RoundedRectangle(cornerRadius: 12)
											.foregroundColor(.white)
											.shadow(color: .black.opacity(0.1), radius: 15)
									)
									.padding(.vertical)
									.listRowBackground(Color.clear)

								} else {
									ForEach(viewModel.bundlingListData.unique(), id: \.id) { item in
										BundlingScheduleCardView(
											onTapButton: {
												viewModel.talentRouteToBundlingDetail(bundleId: item.id.orEmpty())
											},
											onTapEdit: {
												viewModel.routeToBundlingForm(bundleId: item.id.orEmpty())
											},
											onTapDelete: {
                                                viewModel.isShowConfirmAlert = true
                                                viewModel.idToDelete = item.id.orEmpty()
											},
											item: item
										)
										.onAppear {
											if item.id == viewModel.bundlingListData.unique().last?.id {
												viewModel.query.skip = viewModel.query.take
												viewModel.query.take += 15
												
												viewModel.getBundlingList()
											}
										}
										.buttonStyle(.plain)
										.listRowBackground(Color.clear)
                                        .alert(isPresented: $viewModel.isShowConfirmAlert) {
                                            Alert(
                                                title: Text(LocaleText.attention),
                                                message: Text(LocaleText.deleteBundleAlert),
                                                primaryButton: .default(Text(LocaleText.noText)),
                                                secondaryButton: .destructive(Text(LocaleText.yesDeleteText)) {
                                                    withAnimation {
                                                        viewModel.deleteBundling(bundleId: viewModel.idToDelete)
                                                    }
                                                }
                                            )
                                        }
									}
								}

								if viewModel.isLoading {
									HStack {
										Spacer()

										ProgressView()
											.progressViewStyle(.circular)

										Spacer()
									}
									.listRowBackground(Color.clear)
								}
							}
						}
					}
                }
                
                Button(action: {
                    viewModel.routeToCreateBundling()
                }, label: {
                    Image.Dinotis.plusIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                        .padding()
                        .background(Color.DinotisDefault.primary)
                        .clipShape(Circle())
                    
                })
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                .padding()
            }
			.onAppear {
				viewModel.onAppear()
			}
			.onDisappear {
				viewModel.bundlingListData.removeAll()
			}
        }
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
    }
}

struct BundlingView_Previews: PreviewProvider {
    static var previews: some View {
        BundlingView(viewModel: BundlingViewModel(backToHome: {}))
    }
}

extension BundlingView {
	struct HeaderView: View {

		@Environment(\.presentationMode) var presentationMode

		var body: some View {
			HStack {
				Button(action: {
					self.presentationMode.wrappedValue.dismiss()

				}, label: {
					Image.Dinotis.arrowBackIcon
						.padding()
				})
				.background(Color.white)
				.clipShape(Circle())
				.shadow(color: .black.opacity(0.1), radius: 20)

				Spacer()

				Text(LocaleText.talentHomeBundlingMenu)
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)
					.padding(.trailing)

				Spacer()
			}
			.padding()
			.padding(.trailing)
		}
	}
}
