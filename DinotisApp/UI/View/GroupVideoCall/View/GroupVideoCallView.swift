//
//  GroupVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import SwiftUI

struct GroupVideoCallView: View {
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Joined")
            
            Button {
                
            } label: {
                Text("Join Room")
            }
            
            Button {
                
            } label: {
                Text("Leave Room")
            }
            
            Button {
                
            } label: {
                Text("Back")
            }

            
            Spacer()
        }
    }
}

struct GroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideoCallView()
    }
}
