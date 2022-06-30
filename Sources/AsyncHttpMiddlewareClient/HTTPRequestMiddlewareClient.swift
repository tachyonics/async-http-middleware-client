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

public struct HTTPRequestMiddlewareClient: HTTPRequestMiddlewareClientProtocol {
    public let middleware: RequestMiddlewareStack<HTTPClientRequest, HTTPClientResponse>
    public let wrappedHttpClient: HTTPClient
    
    public init(eventLoopGroupProvider: HTTPClient.EventLoopGroupProvider,
                middleware: RequestMiddlewareStack<HTTPClientRequest, HTTPClientResponse>,
                configuration: HTTPClient.Configuration = HTTPClient.Configuration()) {
        self.wrappedHttpClient = HTTPClient(eventLoopGroupProvider: eventLoopGroupProvider,
                                            configuration: configuration)
        self.middleware = middleware
    }

    public init(eventLoopGroupProvider: HTTPClient.EventLoopGroupProvider,
                middleware: RequestMiddlewareStack<HTTPClientRequest, HTTPClientResponse>,
                configuration: HTTPClient.Configuration = HTTPClient.Configuration(),
                backgroundActivityLogger: Logger) {
        self.wrappedHttpClient = HTTPClient(eventLoopGroupProvider: eventLoopGroupProvider,
                                            configuration: configuration,
                                            backgroundActivityLogger: backgroundActivityLogger)
        self.middleware = middleware
    }
    
    public func shutdown() async throws {
        try await self.wrappedHttpClient.shutdown()
    }
}
