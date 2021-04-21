//
//  SettingsView.swift
//  FrostAlert
//
//  Created by Andrew James on 4/21/21.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settingsIsShowing: Bool
    var body: some View {
        NavigationView {
            Text("Test")
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                                print("Dismissing sheet view...")
                                self.settingsIsShowing = false
                            }) {
                                Text("Done").bold()
                            })
    }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var settingsShowing = true
    static var previews: some View {
        SettingsView(settingsIsShowing: $settingsShowing)
    }
}
