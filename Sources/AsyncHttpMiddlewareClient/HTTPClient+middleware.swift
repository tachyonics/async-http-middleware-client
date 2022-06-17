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
//  HTTPClient+middleware.swift
//  AsyncHttpMiddlewareClient
//

import AsyncHTTPClient
import HttpClientMiddleware
import NIOCore
import NIOHTTP1
import Logging

extension HTTPClient {
    public func execute(
        requestBuilder: HttpRequestBuilder<HTTPClientRequest> = HttpRequestBuilder(),
        middleware: RequestMiddlewareStack<HTTPClientRequest, HTTPClientResponse>,
        deadline: NIODeadline,
        logger: Logger? = nil
    ) async throws -> HTTPClientResponse {
        let clientHandler = ClientHandler(httpClient: self, deadline: deadline, logger: logger)
        return try await middleware.handleMiddleware(input: requestBuilder, next: clientHandler)
    }
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

extension HTTPClientRequest: HttpRequestProtocol {
    public typealias BodyType = HTTPClientRequest.Body
    public typealias HeadersType = HTTPHeaders
}

// not great!!
extension HttpClientMiddleware.HttpMethod {
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

extension HttpRequestBuilder where HttpRequestType == HTTPClientRequest {
    public convenience init() {
        func provider(method: HttpMethod,
                      endpoint: Endpoint,
                      headers: HeadersType,
                      body: BodyType?) throws -> HTTPClientRequest {
            var request = HTTPClientRequest(url: endpoint.url?.absoluteString ?? "")
            request.method = method.asHTTPMethod()
            request.headers = headers
            request.body = body
            
            return request
        }
        
        self.init(httpRequestProvider: provider)
    }
}

internal struct ClientHandler<HTTPClientType: HTTPClientProtocol>: HandlerProtocol {
    let httpClient: HTTPClientType
    let deadline: NIODeadline
    let logger: Logger?
    
    func handle(input: HttpRequestBuilder<HTTPClientRequest>) async throws -> HTTPClientType.ResponseType {
        let request = try input.build()
        
        return try await self.httpClient.execute(request, deadline: deadline, logger: logger)
    }
}
