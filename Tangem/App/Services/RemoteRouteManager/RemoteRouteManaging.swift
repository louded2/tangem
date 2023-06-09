//
//  RemoteRouteManaging.swift
//  Tangem
//
//  Created by Sergey Balashov on 09.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine

/// Object's interface for encapsulating logic of deeplink handling
public protocol RemoteRouteManaging: AnyObject {
    var pendingRoute: RemoteRouteModel? { get }

    func becomeFirstResponder(_ responder: RemoteRouteManagerResponder)
    func resignFirstResponder(_ responder: RemoteRouteManagerResponder)

    /// If there is pendingRoute, RemoteRouteManager sends it to all responders, starting from last subscribed
    func tryHandleLastRoute()
    func clearPendingRoute()
}

public protocol RemoteRouteManagerResponder: AnyObject {
    /// Asks responder to handle route. If it returns `true`, previous responders are not called.
    /// If it returns `false`, previous responder is called to handle route.
    /// NOTE: returning `true` does not clear pending route automatically.
    /// To clear call `clearPendingRoute()`.
    func didReceiveRemoteRoute(_ route: RemoteRouteModel) -> Bool
}

private struct RemoteRouteManagingKey: InjectionKey {
    static var currentValue: RemoteRouteManaging = RemoteRouteManager()
}

extension InjectedValues {
    var remoteRouteManager: RemoteRouteManaging {
        get { Self[RemoteRouteManagingKey.self] }
        set { Self[RemoteRouteManagingKey.self] = newValue }
    }
}

