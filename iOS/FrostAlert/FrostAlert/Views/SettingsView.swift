//
//  SettingsView.swift
//  FrostAlert
//
//  Created by Andrew James on 4/21/21.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Binding var settingsIsShowing: Bool
    @Binding var notificationThreshold: Double
    @Binding var cOrF: String
    @EnvironmentObject var docs: DBDocuments
    @Binding var deviceID: String
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Set temperature unit:")
                    .foregroundColor(.gray)
                    .font(.title)
                
                Picker("Unit", selection: $cOrF) {
                    Text("Celsius").tag("Celsius")
                    Text("Fahrenheit").tag("Fahrenheit")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 50)
                
                Spacer()
                
                Text("Set notification threshold:")
                    .foregroundColor(.gray)
                    .font(.title)
                
                Slider(value: $notificationThreshold, in: -2...5, step: 0.2)
                    .padding(.horizontal, 50)
                    .onChange(of: notificationThreshold, perform: { value in
                        docs.changeTempThreshold(newThreshold: notificationThreshold)
                        print(notificationThreshold)
                    })
                Text(cOrF == "Celsius" ? "\(String(format: "%.2f", notificationThreshold))" : "\(String(format: "%.2f", (notificationThreshold*9/5)+32))")
                    .foregroundColor(.blue)
                
                TextField("Device ID", text: $deviceID, onCommit: {
                    docs.setDevice(deviceID: deviceID)
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal, 50)
                
                Spacer().frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: 300, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
  
                Button("Log Out") {
                    let firebaseAuth = Auth.auth()
                    do {
                      try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
                    print("Log out of account & return to Sign in view")
                }
                .padding()
                .font(.title2)
                .foregroundColor(.blue)
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                    print("Dismissing sheet view...")
                    print(cOrF)
                    print(notificationThreshold)
                    self.settingsIsShowing = false
                }) {
                Text("Done").bold().foregroundColor(.blue)
                })
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    @State static var settingsShowing = true
//    @State static var notificationThreshold = 34.0
//    static var previews: some View {
//        SettingsView(settingsIsShowing: $settingsShowing, notificationThreshold: $notificationThreshold)
//    }
//}
