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
import HttpClientMiddleware
import NIOCore
import Logging

internal struct ClientHandler<HTTPClientType: HTTPClientProtocol>: HandlerProtocol {
    let httpClient: HTTPClientType
    let deadline: NIODeadline
    let logger: Logger?
    
    func handle(input: HTTPClientRequest) async throws -> HTTPClientType.ResponseType {
        return try await self.httpClient.execute(input, deadline: deadline, logger: logger)
    }
}
