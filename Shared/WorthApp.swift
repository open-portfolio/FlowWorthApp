//
//  WorthApp.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import os
import SwiftUI

import KeyWindow

import AllocData

import FlowBase
import FlowUI

let log = Logger(subsystem: "app.flowallocator.worth", category: "App")

@main
struct WorthApp: App {
    
    @Environment(\.openURL) var openURL
    
    @StateObject private var infoMessageStore = InfoMessageStore()
    
    var body: some Scene {
        DocumentGroup(newDocument: WorthDocument()) { file in
            ContentView(document: file.$document)
                .environmentObject(infoMessageStore)
                .observeWindow()
        }
        .commands {
            SidebarCommands() // adds a toggle sidebar to View menu
            ToolbarCommands()

            CommandGroup(after: CommandGroupPlacement.importExport) {
                ImportCommand()
            }

            CommandMenu("Builder") {
                BuilderCommand()
            }

            CommandMenu("Returns") {
                ReturnsCommand()
            }

            CommandMenu("Strategy") {
                StrategyCommand()
            }
            
            CommandMenu("Account") {
                AccountCommand()
            }
            
            CommandGroup(before: CommandGroupPlacement.toolbar) {
                ViewCommand()
            }
            
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button(action: {
                    openURL(URL(string: "https://openalloc.github.io/worth/contents/index.html")!)
                }, label: {
                    Text("FlowWorth Help")
                })
            }

            CommandGroup(after: CommandGroupPlacement.help) {
                HelpCommand()
            }
        }
        
        #if os(macOS)
            Settings {
                SharedSettingsView(termsURL: URL(string: "https://openalloc.github.io/terms/")!,
                                   privacyURL: URL(string: "https://openalloc.github.io/privacy/")!) {
                    GeneralView()
                }
                .environmentObject(infoMessageStore)
            }
        #endif
    }
}
