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

public protocol HTTPOperationMiddlewareClientProtocol: GenericHTTPOperationMiddlewareClientProtocol where HTTPClientType == HTTPClient {
    
}

public protocol GenericHTTPOperationMiddlewareClientProtocol {
    associatedtype HTTPClientType: HTTPClientProtocol
    associatedtype InputType
    associatedtype OutputType
    
    typealias MiddlewareStackType = ClientOperationMiddlewareStack<InputType, OutputType, HTTPClientRequest, HTTPClientType.ResponseType>
    
    var middleware: MiddlewareStackType { get }
    var wrappedHttpClient: HTTPClientType { get }
}

public extension GenericHTTPOperationMiddlewareClientProtocol {
    func execute(
        input: InputType,
        deadline: NIODeadline = .distantFuture,
        logger: Logger? = nil,
        middlewareModifier: (inout MiddlewareStackType) -> Void = { _ in }
    ) async throws -> OutputType {
        var requestMiddleware = self.middleware
        middlewareModifier(&requestMiddleware)
        
        return try await self.wrappedHttpClient.execute(middleware: requestMiddleware, input: input,
                                                        deadline: deadline, logger: logger)
    }
}
