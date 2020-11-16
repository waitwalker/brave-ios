// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import WebKit

extension WKUserContentController {
    public func addInDefaultContentWorld(scriptMessageHandler: WKScriptMessageHandler, name: String) {
        if #available(iOS 14.0, *) {
            add(scriptMessageHandler, contentWorld: .defaultClient, name: name)
        } else {
            add(scriptMessageHandler, name: name)
        }
    }
}

extension WKUserScript {
    public class func createInDefaultContentWorld(source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool) -> WKUserScript {
        if #available(iOS 14.0, *) {
            return WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly, in: .defaultClient)
        } else {
            return WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
        }
    }
}
