//
//  ContentView.swift
//  FrostAlert
//
//  Created by Andrew James on 4/11/21.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
let primary: Color = .gray

struct ContentView: View {
    @State var settingsIsShowing = false
    @State var notificationThreshold = 2.0
    @State var cOrF: String = "Celsius"
    @EnvironmentObject var session: SessionStore
    @ObservedObject private var docs = DBDocuments()
    @State var deviceID: String = ""
    
    var body: some View {
        Group {
            if session.session == nil {
                SignInView()
            } else {
                VStack {
                    let endpoint = docs.endpoint
                    Spacer()
                    Text(endpoint?.id ?? "not connected")
                        .font(.largeTitle)
                        //.padding()
                    //Text("\(session.FCMToken ?? "")")
                    if cOrF == "Celsius" {
                        Text(String(format: "%.2f%@", endpoint?.currentTemp ?? 0.0, "ºC"))
                            .padding()
                            .font(.custom("Temp", size: 40, relativeTo: .largeTitle))
                    } else {
                        Text(String(format: "%.2f%@", ((endpoint?.currentTemp ?? 0.0)*9/5)+32, "ºF"))
                            .padding()
                            .font(.custom("Temp", size: 40, relativeTo: .largeTitle))
                    }
                    Text(String(format: "%.1f %@", endpoint?.currentHum ?? 0.0, "%"))
                        .font(.largeTitle)
                    Text("Relative Humidity")
                        .padding(.bottom)
                        .font(.title2)
                    Spacer()
                    Image(systemName: "snow")
                        .font(.custom("Symbol", size: 80, relativeTo: .largeTitle))
                        .padding()
                    Button("Settings") {
                        settingsIsShowing = true
                    }
                        .padding()
                        .foregroundColor(.blue)
                        .sheet(isPresented: $settingsIsShowing, content: {
                            SettingsView(settingsIsShowing: $settingsIsShowing, notificationThreshold: $notificationThreshold, cOrF: $cOrF, deviceID: $deviceID)
                                .environmentObject(docs)
                        })
                }
                .onAppear() {
                    self.docs.loadDBUser(uid: session.session?.uid ?? "")
                }
                .foregroundColor(primary)
            }
        }.onAppear() {
            session.listen()
            print("contentview")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ContentView()
//        }
//    }
//}
