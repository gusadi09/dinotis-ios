//
//  FormScheduleTalentCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/08/21.
//

import SwiftUI

struct FormScheduleTalentCardView: View {
	@Binding var meetingForm: MeetingForm
	@State var isPresent = false
	@State var timeStart: Date?
	@State var timeEnd: Date?
	@State var showsDatePicker = false
	@State var showsTimePicker = false
	@State var showsTimeUntilPicker = false
	@State var sessionPresent = false
	@State var peopleGroup = ""
	@State var estPrice = 0
	@State var pricePerPeople = ""

	@State var isValidPersonForGroup = false
	
	@State var changedTimeStart: Date = Date()
	@State var changedTimeEnd: Date = Date().addingTimeInterval(3600)
	@State var changedDate: Date = Date()
	
	var arrSession = [NSLocalizedString("private_call_label", comment: ""), LocaleText.groupcallLabel]
	
	var onTapRemove: (() -> Void)
	
	var isShowRemove: Bool = false
	
	var isEdit: Bool
	
	@State var selected = ""
	
	var body: some View {
		ZStack(alignment: .top) {
			ZStack(alignment: .topTrailing) {
				VStack(spacing: 20) {
					VStack(spacing: 10) {
						HStack {
							Image("ic-vidcall-form")
								.resizable()
								.scaledToFit()
								.frame(height: 11)
							
							Text(NSLocalizedString("title_description", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}
						
						VStack {
							TextField(NSLocalizedString("example_title", comment: ""), text: $meetingForm.title)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.autocapitalization(.words)
								.disableAutocorrection(true)
								.foregroundColor(.black)
								.accentColor(.black)
								.padding(.horizontal)
								.padding(.vertical, 15)
								.overlay(
									RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
								)
							
							MultilineTextField(text: $meetingForm.description)
								.foregroundColor(.black)
								.accentColor(.black)
								.padding(.horizontal, 10)
								.padding(.vertical, 10)
								.overlay(
									RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
								)
						}
					}
					
					VStack(spacing: 10) {
						HStack {
							Image("ic-calendar")
								.resizable()
								.scaledToFit()
								.frame(height: 20)
							
							Text(NSLocalizedString("select_date", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}
						
						HStack {
							Text("\(itemFormatter.string(from: timeStart.orCurrentDate()))")
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
							
							Spacer()
							
							Image("ic-chevron-bottom")
								.resizable()
								.scaledToFit()
								.frame(height: 15)
						}
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 6))
						.padding(.horizontal)
						.padding(.vertical, 15)
						.onTapGesture {
							self.showsDatePicker.toggle()
							self.showsTimePicker = false
							self.showsTimeUntilPicker = false
							self.sessionPresent = false
							UIApplication.shared.endEditing()
						}
						.overlay(
							RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
						)
					}
					
					VStack(spacing: 10) {
						HStack {
							Image("ic-clock")
								.resizable()
								.scaledToFit()
								.frame(height: 20)
							
							Text(NSLocalizedString("select_time", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}
						
						HStack {
							HStack {
								Text("\(timeFormatter.string(from: timeStart.orCurrentDate()))")
									.font(Font.custom(FontManager.Montserrat.regular, size: 12))
									.foregroundColor(.black)
									.valueChanged(value: timeStart.orCurrentDate()) { value in
										if meetingForm.endAt.isEmpty {
											timeEnd = value.addingTimeInterval(3600)
											meetingForm.endAt = dateISOFormatter.string(from: timeEnd.orCurrentDate())
										}
									}
									.valueChanged(value: changedTimeStart) { value in
										timeEnd = value.addingTimeInterval(3600)
										meetingForm.endAt = dateISOFormatter.string(from: timeEnd.orCurrentDate())
									}
								
								Spacer()
								
								Image("ic-chevron-bottom")
									.resizable()
									.scaledToFit()
									.frame(height: 15)
							}
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 6))
							.padding(.horizontal)
							.padding(.vertical, 15)
							.onTapGesture {
								self.showsTimePicker.toggle()
								self.showsTimeUntilPicker = false
								self.sessionPresent = false
								UIApplication.shared.endEditing()
							}
							.overlay(
								RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
							)
							
							HStack {
								Text("\(timeFormatter.string(from: timeEnd.orCurrentDate()))")
									.font(Font.custom(FontManager.Montserrat.regular, size: 12))
									.foregroundColor(.black)
								
								Spacer()
								
								Image("ic-chevron-bottom")
									.resizable()
									.scaledToFit()
									.frame(height: 15)
							}
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 6))
							.padding(.horizontal)
							.padding(.vertical, 15)
							.onTapGesture {
								self.showsTimeUntilPicker.toggle()
								self.showsTimePicker = false
								self.sessionPresent = false
								UIApplication.shared.endEditing()
							}
							.overlay(
								RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
							)
						}
					}
					.onAppear {
						timeStart = dateISOFormatter.date(from: meetingForm.startAt) ?? Date()
						timeEnd = dateISOFormatter.date(from: meetingForm.endAt) ?? Date().addingTimeInterval(3600)
						
						selected = meetingForm.isPrivate ? NSLocalizedString("private_call_label", comment: "") : NSLocalizedString("group_call_label", comment: "")
						
						peopleGroup = meetingForm.isPrivate ? "1" : String(meetingForm.slots)
						
						pricePerPeople = String(meetingForm.price)

						isValidPersonForGroup = meetingForm.slots > 1
					}
					
					VStack(spacing: 10) {
						HStack {
							Image("ic-session")
								.resizable()
								.scaledToFit()
								.frame(height: 20)
							
							Text(NSLocalizedString("select_session_type", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}

						VStack(alignment: .leading, spacing: 8) {
						HStack {
							Menu {
								Picker(selection: $selected) {
									ForEach(arrSession, id: \.self) { item in
										Text(item)
											.tag(item)
									}
								} label: {
									EmptyView()
								}
							} label: {
								HStack(spacing: 10) {
									Text(selected)
										.lineLimit(1)
										.font(.montserratRegular(size: 12))
										.foregroundColor(.black)

									Spacer()

									Image(systemName: "chevron.down")
										.resizable()
										.scaledToFit()
										.frame(height: 5)
										.foregroundColor(.black)
								}
								.padding(.horizontal, 15)
								.padding(.vertical)
								.background(
									RoundedRectangle(cornerRadius: 10)
										.foregroundColor(.white)
								)
								.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0))
								.onChange(of: selected) { val in
									meetingForm.isPrivate = val == NSLocalizedString("private_call_label", comment: "")
								}
							}
							
							if selected == NSLocalizedString("group_call_label", comment: "") {
								TextField(NSLocalizedString("set_participant", comment: ""), text: $peopleGroup)
									.font(Font.custom(FontManager.Montserrat.regular, size: 12))
									.autocapitalization(.words)
									.disableAutocorrection(true)
									.keyboardType(.numberPad)
									.foregroundColor(.black)
									.accentColor(.black)
									.padding(.horizontal)
									.padding(.vertical, 15)
									.overlay(
										RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
									)
									.frame(width: 95)
									.keyboardType(.numberPad)
									.valueChanged(value: peopleGroup) { value in
										if let intVal = Int(value) {
											meetingForm.slots = intVal
											
											let intPeople = Int(peopleGroup)
											let intPrice = Int(pricePerPeople)
											estPrice = (intPrice ?? 0) * (intPeople ?? 0)

											isValidPersonForGroup = Int(value).orZero() > 1
										}
									}
							}
						}

							if !isValidPersonForGroup && selected == NSLocalizedString("group_call_label", comment: "") {
								HStack {
									Image.Dinotis.exclamationCircleIcon
										.resizable()
										.scaledToFit()
										.frame(height: 10)
										.foregroundColor(.red)
									Text("Participants for Group call must more than 1")
										.font(.montserratRegular(size: 10))
										.foregroundColor(.red)

									Spacer()
								}
							}
						}
					}
					
					VStack(spacing: 10) {
						HStack {
							Image("ic-pricetag")
								.resizable()
								.scaledToFit()
								.frame(height: 20)
							
							Text(NSLocalizedString("set_cost", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}
						
						VStack {
							HStack {
								Text("Rp")
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(.black)
								
								TextField(NSLocalizedString("enter_cost_label", comment: ""), text: $pricePerPeople, onCommit: {
									let intPeople = Int(peopleGroup)
									let intPrice = Int(pricePerPeople)
									estPrice = (intPrice ?? 0) * (intPeople ?? 0)
								})
								.disabled(isEdit)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.autocapitalization(.words)
								.disableAutocorrection(true)
								.keyboardType(.numberPad)
								.foregroundColor(.black)
								.accentColor(.black)
								.valueChanged(value: pricePerPeople) { value in
									if let intPrice = Int(value) {
										meetingForm.price = intPrice
										
										let intPeople = Int(peopleGroup)
										let intPrice = Int(pricePerPeople)
										estPrice = (intPrice ?? 0) * (intPeople ?? 0)

									}
								}
								
								if selected == NSLocalizedString("group_call_label", comment: "") {
									Text(NSLocalizedString("per_person", comment: ""))
										.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
										.foregroundColor(Color("btn-stroke-1"))
								}
								
							}
							.padding(.horizontal)
							.padding(.vertical, 15)
							.background(
								RoundedRectangle(cornerRadius: 6)
									.foregroundColor(isEdit ? .gray.opacity(0.1) : .white)
							)
							.overlay(
								RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
							)
						}
						
						if selected == NSLocalizedString("group_call_label", comment: "") {
							HStack(spacing: 5) {
								Text(NSLocalizedString("estimated_revenue", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 10))
									.foregroundColor(.black)
								
								Text("Rp\(estPrice)")
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(Color("btn-stroke-1"))
								Spacer()
							}
						}
					}
				}
				.padding(20)
				.background(Color.white)
				.cornerRadius(12)
				.shadow(color: Color("dinotis-shadow-1").opacity(0.07), radius: 10, x: 0.0, y: 0.0)
				.padding(.horizontal)
				
				Button {
					onTapRemove()
				} label: {
					Image(systemName: "minus.circle.fill")
						.foregroundColor(.red)
				}
				.padding(.trailing, 10)
				.isHidden(!isShowRemove, remove: !isShowRemove)
			}
			.sheet(isPresented: $showsDatePicker) {
				ZStack {
					VStack(alignment: .center, spacing: 0) {
						DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: .date)
							.datePickerStyle(WheelDatePickerStyle())
							.labelsHidden()
						
						Button(action: {
							timeStart = changedTimeStart
							meetingForm.startAt = changedTimeStart.toString(format: .utcV2)
							showsDatePicker = false
						}, label: {
							HStack {
								Spacer()
								
								Text(NSLocalizedString("select_text", comment: ""))
									.foregroundColor(.white)
									.font(.custom(FontManager.Montserrat.medium, size: 14))
								
								Spacer()
							}
							.padding(.vertical)
							.background(Color("btn-stroke-1"))
						})
						.clipShape(RoundedRectangle(cornerRadius: 8.0))
					}
					.padding()
					.onAppear {
						changedTimeStart = timeStart.orCurrentDate()
					}
				}
			}
			.sheet(isPresented: $showsTimePicker) {
				ZStack {
					VStack(alignment: .leading) {
						HStack {
							Spacer()
							
							DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: .hourAndMinute)
								.datePickerStyle(WheelDatePickerStyle())
								.labelsHidden()
							
							Spacer()
						}
						
						Button(action: {
							timeStart = changedTimeStart
							meetingForm.startAt = changedTimeStart.toString(format: .utcV2)
							showsTimePicker = false
						}, label: {
							HStack {
								Spacer()
								
								Text(NSLocalizedString("select_text", comment: ""))
									.foregroundColor(.white)
									.font(.custom(FontManager.Montserrat.medium, size: 14))
								
								Spacer()
							}
							.padding(.vertical)
							.background(Color("btn-stroke-1"))
						})
						.clipShape(RoundedRectangle(cornerRadius: 8.0))
						.onAppear {
							if changedTimeStart < Date() {
								changedTimeStart = Date()
							}
						}
					}
					.padding()
				}
			}
			.sheet(isPresented: $showsTimeUntilPicker) {
				ZStack {
					VStack(alignment: .leading) {
						HStack {
							Spacer()
							
							DatePicker("", selection: $changedTimeEnd, in: timeStart.orCurrentDate()..., displayedComponents: .hourAndMinute)
								.datePickerStyle(WheelDatePickerStyle())
								.labelsHidden()
							
							Spacer()
						}
						
						Button(action: {
							timeEnd = changedTimeEnd
							meetingForm.endAt = changedTimeEnd.toString(format: .utcV2)
							showsTimeUntilPicker = false
						}, label: {
							HStack {
								Spacer()
								
								Text(NSLocalizedString("select_text", comment: ""))
									.foregroundColor(.white)
									.font(.custom(FontManager.Montserrat.medium, size: 14))
								
								Spacer()
							}
							.padding(.vertical)
							.background(Color("btn-stroke-1"))
						})
						.clipShape(RoundedRectangle(cornerRadius: 8.0))
					}
					.padding()
					.onAppear {
						changedTimeEnd = timeEnd.orCurrentDate()
					}
				}
			}

		}
	}

}

private let dateISOFormatter: DateFormatter = {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	return dateFormatter
}()

private let dateFormatter: DateFormatter = {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale.current
	dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	return dateFormatter
}()

private let itemFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.dateFormat = "dd / MM / yyyy"
	return formatter
}()

private let timeFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.dateFormat = "HH : mm a"
	return formatter
}()

struct FormScheduleTalentCardView_Previews: PreviewProvider {
	static var previews: some View {
		FormScheduleTalentCardView(
			meetingForm: .constant(
				MeetingForm(
					id: UUID().uuidString,
					title: "",
					description: "",
					price: 0, startAt: "",
					endAt: "",
					isPrivate: true,
					slots: 0
				)
			),
			onTapRemove: {},
			isEdit: false
		)
	}
}
