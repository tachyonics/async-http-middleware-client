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
import HttpClientMiddleware
import AsyncHTTPClient
import NIO
import NIOFoundationCompat

public struct HTTPClientRequestJSONEncodableSerializationTransform<InputType: Encodable>: SerializationTransformProtocol {
    public typealias HTTPRequestType = HTTPClientRequest
    
    private let encoder = JSONEncoder()
    
    public init() {
        
    }
    
    public func transform(input: SerializationTransformInput<InputType, HTTPClientRequest>) async throws
    -> HttpRequestBuilder<HTTPClientRequest> {
        let bodyData = try self.encoder.encode(input.operationInput)
        
        let builder = input.builder
        builder.withBody(.bytes(ByteBuffer(data: bodyData)))
        return builder
    }
}