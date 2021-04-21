//
//  SettingsView.swift
//  FrostAlert
//
//  Created by Andrew James on 4/21/21.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settingsIsShowing: Bool
    @Binding var notificationThreshold: Double
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Set temperature unit:")
                    .foregroundColor(.gray)
                    .font(.title)
                
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                    Text("Celsius").tag("C")
                    Text("Fahrenheit").tag("F")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 50)
                
                Spacer()
                
                Text("Set notification threshold:")
                    .foregroundColor(.gray)
                    .font(.title)
                
                Slider(value: $notificationThreshold, in: 30...40)
                    .padding(.horizontal, 50)
                
                Spacer().frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: 300, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Button("Change Device") {
                    print("Go to change device view")
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
                
                Button("Log Out") {
                    print("Log out of account & return to Sign in view")
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                    print("Dismissing sheet view...")
                    self.settingsIsShowing = false
                }) {
                Text("Done").bold().foregroundColor(.blue)
                })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var settingsShowing = true
    @State static var notificationThreshold = 34.0
    static var previews: some View {
        SettingsView(settingsIsShowing: $settingsShowing, notificationThreshold: $notificationThreshold)
    }
}
