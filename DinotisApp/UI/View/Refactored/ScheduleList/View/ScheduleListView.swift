//
//  ScheduleListView.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import SwiftUI
import SwiftUINavigation

struct ScheduleListView: View {
	
	@ObservedObject var viewModel: ScheduleListViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var bookingVm = UserBookingViewModel.shared
	
	var body: some View {
		ZStack {
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.bookingInvoice,
				destination: { viewModel in
					UserInvoiceBookingView(
						bookingId: self.viewModel.bookingID,
						viewModel: viewModel.wrappedValue
					)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.detailPayment,
				destination: {viewModel in
					DetailPaymentView(methodId: $viewModel.methodId, price: $viewModel.invoicePrice, viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.paymentMethod,
				destination: {viewModel in
					PaymentMethodView(
						viewModel: viewModel.wrappedValue
					)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
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
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.historyList,
				destination: {viewModel in
					UserHistoryView(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.userScheduleDetail,
				destination: {viewModel in
					UserScheduleDetail(viewModel: viewModel.wrappedValue)
				},
				onNavigate: {_ in},
				label: {
					EmptyView()
				}
			)
			
			Image("linear-gradient-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					Color.white
						.frame(height: 10)
					
					ZStack {
						HStack {
							Button(action: {
								presentationMode.wrappedValue.dismiss()
							}, label: {
								Image("ic-chevron-back")
									.padding()
									.background(Color.white)
									.clipShape(Circle())
							})
							
							Spacer()
						}
						
						HStack {
							Spacer()
							Text(LocaleText.videoCallSchedule)
								.font(.custom(FontManager.Montserrat.bold, size: 14))
								.padding(.horizontal)
							Spacer()
						}
						
						HStack {
							Spacer()
							
							Button {
								viewModel.routeToUserHistory()
							} label: {
								Text(LocaleText.historyText)
									.font(.custom(FontManager.Montserrat.bold, size: 14))
									.padding(.horizontal)
									.foregroundColor(.primaryViolet)
							}
						}
						
					}
					.padding(.top)
					.padding(10)
					.background(Color.white.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 20))
				}
				
				ScrollViews(axes: .vertical, showsIndicators: false) { value in
					if value.y > 5 {
						bookingVm.getBookings()
					}
				} content: {

						LazyVStack {
							if viewModel.isLoading {
								ActivityIndicator(isAnimating: $viewModel.isLoading, color: .black, style: .medium)
							}
							
							if let data = bookingVm.data?.data.filter({ value in
								value.doneAt == nil &&
								value.canceledAt == nil &&
								!(value.bookingPayment.failedAt != nil && value.meeting.startedAt != nil) &&
								!(value.bookingPayment.failedAt != nil && !isStillShowing(date: (value.meeting.endAt?.toDate(format: .utc)).orCurrentDate())) &&
								value.meeting.endedAt == nil
							}) {
								if data.isEmpty {
									VStack(spacing: 10) {
										
										Image("empty-schedule-img")
											.resizable()
											.scaledToFit()
											.frame(
												minWidth: 0,
												idealWidth: 203,
												maxWidth: 203,
												minHeight: 0,
												idealHeight: 137,
												maxHeight: 137,
												alignment: .center
											)
										
										Text(NSLocalizedString("no_schedule_label", comment: ""))
											.font(Font.custom(FontManager.Montserrat.bold, size: 14))
											.foregroundColor(.black)
										
										Text(NSLocalizedString("find_idol_label", comment: ""))
											.font(Font.custom(FontManager.Montserrat.regular, size: 12))
											.multilineTextAlignment(.center)
											.foregroundColor(.black)
										
										NavigationLink(
											unwrapping: $viewModel.route,
											case: /HomeRouting.searchTalent,
											destination: { viewModel in
												SearchTalentView(viewModel: viewModel.wrappedValue)
											},
											onNavigate: {_ in},
											label: {
												EmptyView()
											}
										)
										
										Button(action: {
											viewModel.routeToSearch()
										}, label: {
											HStack {
												Spacer()
												Text(NSLocalizedString("find_idol", comment: ""))
													.font(Font.custom(FontManager.Montserrat.bold, size: 12))
													.foregroundColor(.white)
													.padding()
												Spacer()
											}
											.background(Color("btn-stroke-1"))
											.cornerRadius(8)
											.padding()
										})
									}
									.padding()
									.background(Color.white)
									.cornerRadius(12)
									.padding(.horizontal)
									.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 15, x: 0.0, y: 0.0)
									.padding(.top, 30)
									
									Spacer()
								} else {
									ForEach(data, id: \.id) { items in
										if let user = items.meeting.user {
											UserScheduleCardView(
												user: .constant(user),
												meeting: .constant(items.meeting),
												payment: .constant(items.bookingPayment),
												currentUserId: $viewModel.currentUserId,
												onTapButton: {
													if items.bookingPayment.paidAt == nil &&
															items.bookingPayment.failedAt != nil {
														
														if (items.meeting.bookings?.filter({ value in
															value.bookingPayment.paidAt != nil &&
															value.bookingPayment.failedAt == nil &&
															(value.user.id).orEmpty() != viewModel.currentUserId
														}).count).orZero() < items.meeting.slots.orZero() {
															if items.meeting.slots == 1 {
																viewModel.meetingId = items.meeting.id
																viewModel.routeToPayment(price: items.meeting.price.orEmpty())
															}
														}
													} else if items.bookingPayment.paidAt == nil &&
																			items.bookingPayment.failedAt == nil {
														viewModel.bookingID = items.bookingPayment.bookingID.orEmpty()
														
														viewModel.invoicePrice = Int(items.bookingPayment.amount.orEmpty()).orZero()
														
														viewModel.methodName = (items.bookingPayment.paymentMethod?.name).orEmpty()
														viewModel.methodIcon = (items.bookingPayment.paymentMethod?.iconURL).orEmpty()
														viewModel.qrCodeUrl = items.bookingPayment.qrCodeUrl
														viewModel.redirectUrl = items.bookingPayment.redirectUrl
														viewModel.methodId = (items.bookingPayment.paymentMethod?.id).orZero()
														viewModel.isEwallet = items.bookingPayment.paymentMethod?.isEwallet ?? false
														viewModel.isQr = items.bookingPayment.paymentMethod?.isQr ?? false
														
														viewModel.routeToInvoice()
													} else {
														viewModel.meetingID = items.bookingPayment.bookingID.orEmpty()
														viewModel.routeToUsertDetailSchedule()
													}
													
												},
												onTapProfile: {
													viewModel.username = (items.meeting.user?.username).orEmpty()
													viewModel.routeToTalentProfile()
												},
												onTapDetailPaymennt: {
													viewModel.bookingID = items.bookingPayment.bookingID.orEmpty()
													viewModel.invoicePrice = Int(items.bookingPayment.amount.orEmpty()) ?? 0
													viewModel.paymentName = (items.bookingPayment.paymentMethod?.name).orEmpty()
													viewModel.qrCodeUrl = items.bookingPayment.qrCodeUrl
													viewModel.redirectUrl = items.bookingPayment.redirectUrl
													
													viewModel.routeToInvoiceBooking()
												}
											)
										}
									}
									.padding(.vertical, 15)
									
								}
							}
						}
				}
			}
		}
		.edgesIgnoringSafeArea(.vertical)
		.onAppear {
			bookingVm.getBookings()
		}
		.valueChanged(value: bookingVm.success, onChange: { value in
			DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
				withAnimation(.spring()) {
					if value {
						viewModel.isLoading = false
					}
				}
			})
		})
		.valueChanged(value: bookingVm.isLoading) { value in
			DispatchQueue.main.async {
				withAnimation(.spring()) {
					if value {
						viewModel.isLoading = true
					}
				}
			}
		}
		
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
	
	private func isStillShowing(date: Date) -> Bool {
		let order = Calendar.current.compare(date, to: Date(), toGranularity: .minute)
		
		switch order {
		case .orderedSame:
			return true
		case .orderedAscending:
			return true
		default:
			return false
		}
	}
}

struct ScheduleListView_Previews: PreviewProvider {
	static var previews: some View {
		ScheduleListView(viewModel: ScheduleListViewModel(backToRoot: {}, backToHome: {}, currentUserId: ""))
	}
}
