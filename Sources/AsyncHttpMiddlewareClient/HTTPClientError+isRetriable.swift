//===----------------------------------------------------------------------===//
//
// This source file is part of the async-http-middleware-client open source project
//
// Copyright (c) 2022 the async-http-middleware-client project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of VSCode Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AsyncHTTPClient

extension HTTPClientError {
    public var isRetriable: Bool {
        switch self {
        case .readTimeout, .connectTimeout, .tlsHandshakeTimeout,
                .remoteConnectionClosed, .getConnectionFromPoolTimeout:
            return true
        default:
            return false
        }
    }
}
