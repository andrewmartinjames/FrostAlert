//
//  ContentView.swift
//  FrostAlert
//
//  Created by Andrew James on 4/11/21.
//

import SwiftUI
let primary: Color = .gray

struct ContentView: View {
    @State var settingsIsShowing = false
    @State var notificationThreshold = 34.0
    @ObservedObject private var endpoints = EndpointRepository()
    
    var body: some View {
        VStack {
            let endpoint = endpoints.endpoints.first
            Spacer()
            Text(endpoint?.id ?? "not connected")
                .font(.largeTitle)
                //.padding()
            Text(String(format: "%.2f%@", endpoint?.currentTemp ?? 0.0, "ºC"))
                .padding()
                .font(.custom("Temp", size: 40, relativeTo: .largeTitle))
            Text(String(format: "%.1f %@", endpoint?.currentHum ?? 0.0, "%"))
                .font(.largeTitle)
            Text("Relative Humidity")
                .padding(.bottom)
                .font(.title2)
            Text("Reported Weather:")
                .font(.title2)
                .padding(.top)
            Text("Cloudy, RTMP ºF")
                .font(.title2)

            Spacer()
            Image(systemName: "snow")
                .font(.custom("Symbol", size: 80, relativeTo: .largeTitle))
                .padding()
            Button("Settings") {
                settingsIsShowing = true
            }
                .foregroundColor(.blue)
                .sheet(isPresented: $settingsIsShowing, content: {
                    SettingsView(settingsIsShowing: $settingsIsShowing, notificationThreshold: $notificationThreshold)
                })
        }
        .onAppear() {
            self.endpoints.loadEndpoints()
            print(endpoints.endpoints.isEmpty)
        }
        .foregroundColor(primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
