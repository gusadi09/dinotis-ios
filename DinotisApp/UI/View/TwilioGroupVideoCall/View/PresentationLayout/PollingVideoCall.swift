//
//  CheckBoxStyle.swift
//  DinotisApp
//
//  Created by mora hakim on 25/06/23.
//

import Foundation
import SwiftUI
struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(configuration.isOn ? .white : .gray)
            configuration.label
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

struct FormData: Identifiable {
    var id = UUID()
    var value: String = ""
    
}

struct PollFinish: View {
    @State var checked = false
    @Binding var form: FormData
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $checked) {
                Text(form.value)
            }
            
            .toggleStyle(CheckboxStyle())
            .padding()
            
            .frame(maxWidth: .infinity)
            .background(!checked ? Color.dinotisBgCheck : Color.blue).cornerRadius(10)
            
            
        }.padding()
        
        
    }
}

struct FormRowView: View {
    @Binding var form: FormData
    
    
    var body: some View {
        VStack {
            
            if #available(iOS 16.0, *) {
                TextField("", text: $form.value, axis: .vertical)
                    .placeholder(when: form.value.isEmpty, placeholder: {
                        Text("Message Here").foregroundColor(.white)
                    })
                    .autocorrectionDisabled(true)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
                            .background(Color.dinotisBgForm)
                    }
                    .padding()
            } else {
                // Fallback on earlier versions
            }
            
            
        }
    }
}

struct HeaderPoll: View {
    @Binding var fieldPoll: String
    var body: some View {
        Text(fieldPoll)
    }
}
