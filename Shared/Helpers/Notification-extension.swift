//
//  Notification-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Notification.Name
{
    static let refreshWorthResult = Notification.Name("refreshWorthResult") // payload of model UUID
    static let commitBuilder = Notification.Name("commitBuilder") // payload of model UUID
    static let clearBuilder = Notification.Name("clearBuilder") // payload of model UUID
}
