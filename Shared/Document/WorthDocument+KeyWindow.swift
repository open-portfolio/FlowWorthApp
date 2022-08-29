//
//  WorthDocument+KeyWindow.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import KeyWindow

// for commands on document see https://lostmoa.com/blog/KeyWindowABetterWayOfExposingValuesFromTheKeyWindow/
extension WorthDocument: KeyWindowValueKey {
    public typealias Value = Binding<Self>
}

