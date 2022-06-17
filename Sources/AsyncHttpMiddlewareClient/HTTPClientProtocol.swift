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
import NIOHTTP1
import Logging

public protocol HTTPClientProtocol {
    associatedtype ResponseType
    
    func execute(
        _ request: HTTPClientRequest,
        deadline: NIODeadline,
        logger: Logger?
    ) async throws -> ResponseType
}

public extension HTTPClientProtocol {
    // provides a method on the `HTTPClientProtocol` - which `HTTPClient` conforms to -
    // that takes an already-created `RequestMiddlewareStack`. Provides the ability to
    // pass a set of middleware per-request without creating a custom client type
    func execute(
        middleware: RequestMiddlewareStack<HTTPClientRequest, ResponseType>,
        requestBuilder: HttpRequestBuilder<HTTPClientRequest> = HttpRequestBuilder(),
        deadline: NIODeadline = .distantFuture,
        logger: Logger? = nil
    ) async throws -> ResponseType {
        let clientHandler = ClientHandler(httpClient: self, deadline: deadline, logger: logger)
        return try await middleware.handleMiddleware(input: requestBuilder, next: clientHandler)
    }
}
