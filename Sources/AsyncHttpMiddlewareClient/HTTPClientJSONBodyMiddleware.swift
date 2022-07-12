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

import Foundation
import HttpMiddleware
import HttpClientMiddleware
import AsyncHTTPClient
import NIO
import NIOFoundationCompat

public struct HTTPClientJSONBodyMiddleware<BodyType: Encodable>: RequestBodyMiddlewareProtocol {
    public typealias InputType = SerializeClientRequestMiddlewarePhaseInput<BodyType, HTTPClientRequest>
    public typealias OutputType = HTTPClientResponse
    
    private let encoder: JSONEncoder
    
    public init(encoder: JSONEncoder = .init()) {
        self.encoder = encoder
    }
    
    public func handle<HandlerType>(input phaseInput: InputType, next: HandlerType) async throws
    -> HTTPClientResponse
    where HandlerType : HandlerProtocol, InputType == HandlerType.InputType, HTTPClientResponse == HandlerType.OutputType {
        let bodyData = try self.encoder.encode(phaseInput.input)
        
        let builder = phaseInput.builder
        builder.withBody(.bytes(ByteBuffer(data: bodyData)))
        return try await next.handle(input: phaseInput)
    }
}
