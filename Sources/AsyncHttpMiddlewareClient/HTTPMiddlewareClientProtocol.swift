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
//  HTTPMiddlewareClientProtocol.swift
//  AsyncHttpMiddlewareClient
//

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
        logger: Logger? = nil
    ) async throws -> HTTPClientType.ResponseType {
        let clientHandler = ClientHandler(httpClient: self.wrappedHttpClient, deadline: deadline, logger: logger)
        return try await self.middleware.handleMiddleware(input: requestBuilder, next: clientHandler)
    }
}
