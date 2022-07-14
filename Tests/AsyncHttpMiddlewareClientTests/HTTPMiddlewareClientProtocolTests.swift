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

import XCTest
@testable import AsyncHttpMiddlewareClient
import HttpMiddleware
import HttpClientMiddleware
import AsyncHTTPClient
import Logging
import NIOCore

private let userAgent1 = "MyUserAgent1"
private let userAgent2 = "MyUserAgent2"

// middleware is generic with respect to the HttpRequest and Response types
struct UserAgentMiddleware<HttpRequestType: HttpClientRequestProtocol,
                            ResponseType: HttpClientResponseProtocol>: UserAgentHeaderMiddlewareProtocol {
    private let USER_AGENT: String = "User-Agent"
    
    let userAgent: String
    
    public init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    public func handle<HandlerType>(input: HttpClientRequestBuilder<HttpRequestType>,
                                    context: MiddlewareContext, next: HandlerType) async throws -> ResponseType
    where HandlerType: MiddlewareHandlerProtocol,
          Self.Input == HandlerType.InputType,
          Self.Output == HandlerType.OutputType {
        input.withHeader(name: USER_AGENT, value: self.userAgent)
        
              return try await next.handle(input: input, context: context)
    }
    
    public typealias Input = HttpClientRequestBuilder<HttpRequestType>
    public typealias Output = ResponseType
}

extension String: HttpClientResponseProtocol {
    public var statusCode: UInt {
        return 500
    }
}

struct TestHTTPClient: HTTPClientProtocol {
    func execute(_ request: HTTPClientRequest, deadline: NIODeadline, logger: Logger?) async throws -> String {
        // return the user agent header as the "response" from this client
        return request.headers["User-Agent"].joined(separator: ",")
    }
    
    
}

// create a custom client that defines its own client-level middleware
// conforms to the `GenericHTTPMiddlewareClientProtocol` protocol for testing so it can use `TestHTTPClient`
// usually custom clients would conform to the `HTTPMiddlewareClientProtocol` which uses `HTTPClient`
struct MyHTTPMiddlewareClient: GenericHTTPRequestMiddlewareClientProtocol {
    public let middleware: ClientRequestMiddlewareStack<HTTPClientRequest, TestHTTPClient.ResponseType>
    public let wrappedHttpClient: TestHTTPClient

    public init() {
        self.wrappedHttpClient = TestHTTPClient()
        
        var middlewareStack = ClientRequestMiddlewareStack<HTTPClientRequest, TestHTTPClient.ResponseType>(id: "MyHTTPMiddleware")
        middlewareStack.buildPhase.intercept(with: UserAgentMiddleware(userAgent: userAgent1))
        
        self.middleware = middlewareStack
    }
}

class HTTPMiddlewareClientProtocolTests: XCTestCase {

    func testCustomMiddlewareClientType() async throws {
        let client = MyHTTPMiddlewareClient()
        
        let response = try await client.execute()
        
        // confirm that the user agent was returned as the "response".
        XCTAssertEqual(userAgent1, response)
    }
    
    func testCustomMiddlewareClientTypeWithOverride() async throws {
        let client = MyHTTPMiddlewareClient()
        
        let response1 = try await client.execute() { middlewareStack in
            // this `UserAgentMiddleware` will "override" the one specified in the client's initializer
            // (it overrides the previous middleware as they have the same "id")
            middlewareStack.buildPhase.intercept(with: UserAgentMiddleware(userAgent: userAgent2))
        }
        
        // confirm that the appropriate user agent was returned as the "response".
        XCTAssertEqual(userAgent2, response1)
        
        let response2 = try await client.execute()
        
        // confirm that the appropriate user agent was returned as the "response".
        // the previous execute-level override shouldn't affect anything
        XCTAssertEqual(userAgent1, response2)
    }
    
    func testDirectlyPassingMiddleware() async throws {
        let client = TestHTTPClient()
        
        var middlewareStack = ClientRequestMiddlewareStack<HTTPClientRequest, TestHTTPClient.ResponseType>(id: "MyHTTPMiddleware")
        middlewareStack.buildPhase.intercept(with: UserAgentMiddleware(userAgent: userAgent1))
        
        let response = try await client.execute(middleware: middlewareStack)
        
        // confirm that the user agent was returned as the "response".
        XCTAssertEqual(userAgent1, response)
    }
}
