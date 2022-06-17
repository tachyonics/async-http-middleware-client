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
// HTTPMiddlewareClientProtocolTests.swift
// AsyncHttpMiddlewareClient
//

import XCTest
@testable import AsyncHttpMiddlewareClient
import HttpClientMiddleware
import AsyncHTTPClient
import Logging
import NIOCore

private let userAgent = "MyUserAgent"

struct UserAgentMiddleware<HttpRequestType: HttpRequestProtocol, OutputType>: MiddlewareProtocol {
    public let id: String = "UserAgentHeader"
    
    private let USER_AGENT: String = "User-Agent"
    
    let userAgent: String
    
    public init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    public func handle<HandlerType>(input: HttpRequestBuilder<HttpRequestType>,
                          next: HandlerType) async throws -> OutputType
    where HandlerType: HandlerProtocol,
          Self.MInput == HandlerType.Input,
          Self.MOutput == HandlerType.Output {
        input.withHeader(name: USER_AGENT, value: self.userAgent)
        
        return try await next.handle(input: input)
    }
    
    public typealias MInput = HttpRequestBuilder<HttpRequestType>
    public typealias MOutput = OutputType
}

struct TestHTTPClient: HTTPClientProtocol {
    func execute(_ request: HTTPClientRequest, deadline: NIODeadline, logger: Logger?) async throws -> Bool {
        XCTAssertEqual(request.headers["User-Agent"], [userAgent])
        
        return true
    }
    
    
}

struct MyHTTPMiddlewareClient: GenericHTTPMiddlewareClientProtocol {
    public let middleware: RequestMiddlewareStack<HTTPClientRequest, Bool>
    public let wrappedHttpClient: TestHTTPClient

    public init() {
        self.wrappedHttpClient = TestHTTPClient()
        
        var middlewareStack = RequestMiddlewareStack<HTTPClientRequest, Bool>(id: "MyHTTPMiddleware")
        middlewareStack.buildPhase.intercept(position: .first, middleware: UserAgentMiddleware(userAgent: userAgent))
        
        self.middleware = middlewareStack
    }
}

class HTTPMiddlewareClientProtocolTests: XCTestCase {

    func testBasicMiddleware() async throws {
        let client = MyHTTPMiddlewareClient()
        
        let response = try await client.execute()
        
        XCTAssertEqual(true, response)
    }
}
