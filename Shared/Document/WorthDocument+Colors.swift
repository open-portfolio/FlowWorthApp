//
//  WorthDocument+Colors.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import FlowBase
import FlowUI

extension WorthDocument {
    
    func getBackgroundFill(_ assetKey: AssetKey) -> AnyView {
        let color = assetColorMap[assetKey]?.1 ?? Color.clear
        return MyColor.getBackgroundFill(color)
    }

    // Get the componentized accent color (which can be manipulated for lighter/darker/etc.)
    static let _accent: Color = {
        let rawColor = Color("AccentColor") // NOTE Color.accentColor produces blue results for mysterious reasons
        return Color.componentize(rawColor)
    }()
    
    var accent: Color {
        WorthDocument._accent
    }
    
    var accentFill: LinearGradient {
        let color = accent
        let lite = color.saturate(by: 0.2)
        let dark = color.desaturate(by: 0.2)
        return LinearGradient(gradient: .init(colors: [lite, dark]), startPoint: .top, endPoint: .bottom)
    }
}
