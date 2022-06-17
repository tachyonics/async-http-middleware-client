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

import HttpClientMiddleware
import AsyncHTTPClient
import NIOCore
import Logging

public protocol HTTPMiddlewareClientProtocol: GenericHTTPMiddlewareClientProtocol where HTTPClientType == HTTPClient {
    
}

public protocol GenericHTTPMiddlewareClientProtocol {
    associatedtype HTTPClientType: HTTPClientProtocol
    
    var middleware: RequestMiddlewareStack<HTTPClientRequest, HTTPClientType.ResponseType> { get }
    var wrappedHttpClient: HTTPClientType { get }
}

public extension GenericHTTPMiddlewareClientProtocol {
    func execute(
        requestBuilder: HttpRequestBuilder<HTTPClientRequest> = HttpRequestBuilder(),
        deadline: NIODeadline = .distantFuture,
        logger: Logger? = nil,
        middlewareModifier: (inout RequestMiddlewareStack<HTTPClientRequest, HTTPClientType.ResponseType>) -> Void = { _ in }
    ) async throws -> HTTPClientType.ResponseType {
        var requestMiddleware = self.middleware
        middlewareModifier(&requestMiddleware)
        
        return try await self.wrappedHttpClient.execute(middleware: requestMiddleware, requestBuilder: requestBuilder,
                                                        deadline: deadline, logger: logger)
    }
}
