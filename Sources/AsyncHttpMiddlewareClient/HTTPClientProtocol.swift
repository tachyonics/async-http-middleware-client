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
import HttpMiddleware
import HttpClientMiddleware
import NIOCore
import NIOHTTP1
import Logging

public protocol HTTPClientProtocol {
    associatedtype ResponseType: HttpClientResponseProtocol
    
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
        middleware: ClientRequestMiddlewareStack<HTTPClientRequest, ResponseType>,
        requestBuilder: HttpClientRequestBuilder<HTTPClientRequest> = HttpClientRequestBuilder(),
        deadline: NIODeadline = .distantFuture,
        logger: Logger? = nil
    ) async throws -> ResponseType {
        let clientHandler = ClientHandler(httpClient: self, deadline: deadline)
        let context = MiddlewareContext(logger: logger ?? Logger(label: "AsyncHTTPMiddlewareClient"))
        return try await middleware.handleMiddleware(input: requestBuilder, context: context, next: clientHandler)
    }
    
    // provides a method on the `HTTPClientProtocol` - which `HTTPClient` conforms to -
    // that takes an already-created `RequestMiddlewareStack`. Provides the ability to
    // pass a set of middleware per-request without creating a custom client type
    func execute<InputType, OutputType>(
        middleware: ClientOperationMiddlewareStack<InputType, OutputType, HTTPClientRequest, ResponseType>,
        input: InputType,
        deadline: NIODeadline = .distantFuture,
        logger: Logger? = nil
    ) async throws -> OutputType {
        let clientHandler = ClientHandler(httpClient: self, deadline: deadline)
        let context = MiddlewareContext(logger: logger ?? Logger(label: "AsyncHTTPMiddlewareClient"))
        return try await middleware.handleMiddleware(input: input, context: context, next: clientHandler)
    }
}
