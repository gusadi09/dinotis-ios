//
//  SwiftUIView.swift
//  
//
//  Created by Garry on 19/01/23.
//

import SwiftUI

public struct DinotisCurrencyTextField: View {
    
    @Binding var amount: Double?
    let label: String?
    @Binding var errorText: String?
    
    public init(
        amount: Binding<Double?>,
        label: String?,
        errorText: Binding<String?>
    ) {
        self._amount = amount
        self.label = label
        self._errorText = errorText
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                Text(label)
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.DinotisDefault.black1)
            }
            
            VStack {
                CurrencyTextField(
                    "Rp0",
                    value: $amount,
                    alwaysShowFractions: false,
                    numberOfDecimalPlaces: 0,
                    currencySymbol: "Rp",
                    font: UIFont(name: Roboto.bold.rawValue, size: 24),
                    accentColor: UIColor(.DinotisDefault.primary)
                )
                
                Capsule()
                    .frame(height: 1)
                    .foregroundColor(!(errorText?.isEmpty ?? false) ? .DinotisDefault.red : Color(UIColor.systemGray4))
            }
            .padding(.top, 8)
            
            if let errorText = errorText {
                Text(errorText)
                    .font(.robotoMedium(size: 10))
                    .foregroundColor(.DinotisDefault.red)
                    .multilineTextAlignment(.leading)
                    .isHidden(errorText.isEmpty, remove: errorText.isEmpty)
            }
        }
    }
}

struct DinotisCTFPreview: View {
    @State var amount: Double? = 0.0
    @State var errorText: String? = "Transaksi kurang dari Rp50.000"

    var body: some View {
        DinotisCurrencyTextField(
            amount: $amount,
            label: "Masukkan Nominal (Min. Rp50.000)",
            errorText: $errorText
        )
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        DinotisCTFPreview()
            .padding()
    }
}
