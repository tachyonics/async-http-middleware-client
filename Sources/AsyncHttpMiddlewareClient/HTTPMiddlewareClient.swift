// Copyright 2018-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//
//  HTTPMiddlewareClient.swift
//  AsyncHttpMiddlewareClient
//

import HttpClientMiddleware
import AsyncHTTPClient
import NIOCore
import Logging

public struct HTTPMiddlewareClient: HTTPMiddlewareClientProtocol {
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
