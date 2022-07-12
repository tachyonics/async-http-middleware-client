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

extension HTTPClient: HTTPClientProtocol {
    public typealias ResponseType = HTTPClientResponse
    
}

extension HTTPHeaders: HttpHeadersProtocol {
    public init() {
        self.init([])
    }
    
    public mutating func replaceOrAdd(name: String, values: [String]) {
        //if self.isConnectionHeader(name) {
        //    self.keepAliveState = .unknown
        //}
        self.remove(name: name)
        self.add(name: name, values: values)
    }
    
    
    
    public mutating func add(name: String, values: [String]) {
        values.forEach { value in
            add(name: name, value: value)
        }
    }
}

extension HTTPClientRequest: HttpClientRequestProtocol {
    public typealias AdditionalRequestPropertiesType = Void
    
    public typealias BodyType = HTTPClientRequest.Body
    public typealias HeadersType = HTTPHeaders
}

extension HTTPClientRequest.Body: HTTPBodyProtocol {

}

extension HTTPClientResponse: HttpClientResponseProtocol {
    public var statusCode: UInt {
        return self.status.code
    }
}

// not great!!
extension HttpMiddleware.HttpMethod {
    func asHTTPMethod() -> NIOHTTP1.HTTPMethod {
        switch self {
        case .GET:
            return .GET
        case .PUT:
            return .PUT
        case .ACL:
            return .ACL
        case .HEAD:
            return .HEAD
        case .POST:
            return .POST
        case .COPY:
            return .COPY
        case .LOCK:
            return .LOCK
        case .MOVE:
            return .MOVE
        case .BIND:
            return .BIND
        case .LINK:
            return .LINK
        case .PATCH:
            return .PATCH
        case .TRACE:
            return .TRACE
        case .MKCOL:
            return .MKCOL
        case .MERGE:
            return .MERGE
        case .PURGE:
            return .PURGE
        case .NOTIFY:
            return .NOTIFY
        case .SEARCH:
            return .SEARCH
        case .UNLOCK:
            return .UNLOCK
        case .REBIND:
            return .REBIND
        case .UNBIND:
            return .UNBIND
        case .REPORT:
            return .REPORT
        case .DELETE:
            return .DELETE
        case .UNLINK:
            return .UNLINK
        case .CONNECT:
            return .CONNECT
        case .MSEARCH:
            return .MSEARCH
        case .OPTIONS:
            return .OPTIONS
        case .PROPFIND:
            return .PROPFIND
        case .CHECKOUT:
            return .CHECKOUT
        case .PROPPATCH:
            return .PROPPATCH
        case .SUBSCRIBE:
            return .SUBSCRIBE
        case .MKCALENDAR:
            return .MKCALENDAR
        case .MKACTIVITY:
            return .MKACTIVITY
        case .UNSUBSCRIBE:
            return .UNSUBSCRIBE
        case .SOURCE:
            return .SOURCE
        case .RAW(value: let value):
            return .RAW(value: value)
        }
    }
}

extension HTTPClientRequest {
    public init(method: HttpMethod,
                endpoint: Endpoint,
                headers: HeadersType,
                body: BodyType?,
                additionalRequestProperties: HTTPClientRequest.AdditionalRequestPropertiesType?) {
        self.init(url: endpoint.url?.absoluteString ?? "")
        self.method = method.asHTTPMethod()
        self.headers = headers
        self.body = body
    }
}
