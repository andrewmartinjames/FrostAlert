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
    var body: some View {
        VStack {
            Text("DeviceName")
                .font(.largeTitle)
                .padding()
            Text("TMP ºF")
                .padding()
                .font(.custom("Temp", size: 40, relativeTo: .largeTitle))
            Text("RH%")
                .font(.largeTitle)
            Text("Relative Humidity")
                .padding(.bottom)
                .font(.headline)
            Text("Reported Weather:")
                .font(.headline)
            Text("Cloudy, RTMP ºF")
                .font(.headline)
            Image(systemName: "snow")
                .font(.custom("Symbol", size: 80, relativeTo: .largeTitle))
                .padding()
            Button("Settings") {
                settingsIsShowing = true
            }
            .foregroundColor(.blue)
            .sheet(isPresented: $settingsIsShowing, content: {
                SettingsView(settingsIsShowing: $settingsIsShowing)
            })
        }
        .foregroundColor(primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
