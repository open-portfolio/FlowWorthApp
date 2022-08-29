//
//  SettingsGeneralView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import KeyWindow

import FlowUI

struct GeneralView: View {
    
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?
    
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""
    @AppStorage(UserDefShared.defTimeOfDay.rawValue) var defTimeOfDay: TimeOfDayPicker.Vals = .useDefault
    
    @State private var updateToggle = false
    
    var body: some View {
        HStack(alignment: .top) {
            Group {
                SettingsTermsView()
                    .padding(.trailing)
                otherView
                HelpButton(appName: "worth", topicName: "settingsGeneral")
            }
        }
        .padding()
    }
    
    private var otherView: some View {
        StatsBoxView(title: "Other") {
            
            VStack(alignment: .leading) {
                TimeZonePicker(timeZoneID: $timeZoneID)
                Text("Used in parsing dates and times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            VStack(alignment: .leading) {
                TimeOfDayPicker(title: "Default Time of Day", timeOfDay: $defTimeOfDay)
                Text("Used in parsing dates and times")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Button("Restore Defaults", action: {
                UserDefaults.clear()
            })
                .padding()
            
            Spacer()
        }
    }
}
