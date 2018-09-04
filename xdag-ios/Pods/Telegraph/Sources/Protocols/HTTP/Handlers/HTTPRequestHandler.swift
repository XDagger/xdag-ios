//
//  HTTPRequestHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/19/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol HTTPRequestHandler {
  func respond(to request: HTTPRequest, nextHandler: HTTPRequest.Handler) throws -> HTTPResponse?
}

extension HTTPRequest {
  public typealias Handler = (HTTPRequest) throws -> HTTPResponse?
}

extension Collection where Iterator.Element == HTTPRequestHandler {
  func chain(lastHandler: @escaping HTTPRequest.Handler = { _ in return nil }) -> HTTPRequest.Handler {
    // Creates a closure chain with all of the handlers
    return reversed().reduce(lastHandler) { nextHandler, handler in
      return { request in try handler.respond(to: request, nextHandler: nextHandler) }
    }
  }
}
