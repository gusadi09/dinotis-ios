//
//  CountryPickerView.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/09/22.
//

import SwiftUI
import CountryPicker

struct CountryPicker: UIViewControllerRepresentable {
	typealias UIViewControllerType = CountryPickerViewController

	let configMaker = Config(
		selectedCountryCodeBackgroundColor: UIColor(named: "btn-stroke-1") ?? UIColor.purple,
		closeButtonTextColor: UIColor(named: "btn-stroke-1") ?? UIColor.purple,
		closeButtonText: LocaleText.generalClose,
		titleText: LocaleText.selectCountry,
		searchBarPlaceholder: LocaleText.generalSearch
	)

	@Binding var country: Country

	func makeUIViewController(context: Context) -> CountryPickerViewController {

		CountryManager.shared.config = configMaker

		let countryPicker = CountryPickerViewController()
		countryPicker.selectedCountry = country.isoCode
		countryPicker.delegate = context.coordinator

		return countryPicker
	}

	func updateUIViewController(_ uiViewController: CountryPickerViewController, context: Context) {

		CountryManager.shared.config = configMaker
		uiViewController.selectedCountry = country.isoCode
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	class Coordinator: NSObject, CountryPickerDelegate {
		var parent: CountryPicker
		init(_ parent: CountryPicker) {
			self.parent = parent
		}
		func countryPicker(didSelect country: Country) {
			parent.country = country
		}
	}
}
