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
import AsyncHTTPClient
import NIO
import NIOFoundationCompat

public enum DeserializationError: Error {
    case missingBody(HTTPClientResponse)
}

public struct HTTPClientResponseJSONDecodableDeserializationTransform<OutputType: Decodable>: DeserializationTransformProtocol {
    public typealias HTTPResponseType = HTTPClientResponse
    
    private let decoder: JSONDecoder
    private let maxBytes: Int
    
    public init(maxBytes: Int, decoder: JSONDecoder = .init()) {
        self.maxBytes = maxBytes
        self.decoder = decoder
    }
    
    public func transform(input: HTTPClientResponse) async throws -> OutputType {
        var bodyBuffer = try await input.body.collect(upTo: self.maxBytes)
        
        let byteBufferSize = bodyBuffer.readableBytes
        guard let bodyData = bodyBuffer.readData(length: byteBufferSize) else {
            throw DeserializationError.missingBody(input)
        }
        
        return try self.decoder.decode(OutputType.self, from: bodyData)
    }
}
