//
//  Server+Routing.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/19/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

extension Server {
  /// Adds a route handler consisting of a HTTP method, uri and handler closure.
  public func route(_ method: HTTPMethod, _ uri: String, _ handler: @escaping HTTPRequest.Handler) {
    guard let httpRoute = try? HTTPRoute(methods: [method], uri: uri, handler: handler) else {
      fatalError("Could not add route - invalid uri: \(uri)")
    }

    route(httpRoute)
  }

  /// Adds a route handler consisting of a HTTP method, uri regex and handler closure.
  public func route(_ method: HTTPMethod, regex: String, _ handler: @escaping HTTPRequest.Handler) {
    guard let httpRoute = try? HTTPRoute(methods: [method], regex: regex, handler: handler) else {
      fatalError("Could not add route - invalid regex: \(regex)")
    }

    route(httpRoute)
  }

  /// Adds a route.
  public func route(_ httpRoute: HTTPRoute) {
    guard let routeHandler = httpConfig.requestHandlers.first(ofType: HTTPRouteHandler.self) else {
      fatalError("Could not add route - the server doesn't have a route handler")
    }

    routeHandler.routes.append(httpRoute)
  }
}

// MARK: Serve static content methods

extension Server {
  /// Adds a route that serves files from a bundle.
  public func serveBundle(_ bundle: Bundle, _ uri: String = "/", index: String? = "index.html") {
    serveDirectory(bundle.resourceURL!, uri, index: index)
  }

  /// Adds a route that serves files from a directory.
  public func serveDirectory(_ url: URL, _ uri: String = "/", index: String? = "index.html") {
    var baseURI = URI(path: uri)

    // Construct the uri, do not match exactly to support subdirectories
    var routeURI = baseURI.path
    if !routeURI.hasSuffix("*") {
      if !routeURI.hasSuffix("/") { routeURI += "/" }
      routeURI += "*"
    }

    // Wrap the file handler into a route
    let handler = HTTPFileHandler(directoryURL: url, baseURI: baseURI, index: index)
    route(.get, routeURI) { request in try handler.respond(to: request, nextHandler: { _ in HTTPResponse(.notFound) }) }
  }
}

// MARK: Response helper methods

extension Server {
  /// Adds a route that responds to *method* on *uri* that responds with a *response*.
  public func route(_ method: HTTPMethod, _ uri: String, response: @escaping () -> HTTPResponse) {
    route(method, uri, { _ in response() })
  }

  /// Adds a route that responds to *method* on *uri* that responds with a *statusCode*.
  public func route(_ method: HTTPMethod, _ uri: String, statusCode: @escaping () -> HTTPStatusCode) {
    route(method, uri, { _ in HTTPResponse(statusCode()) })
  }

  /// Adds a route that responds to *method* on *uri* that responds with *statusCode* and text content.
  public func route(_ method: HTTPMethod, _ uri: String, content: @escaping () -> (HTTPStatusCode, String)) {
    route(method, uri, { _ in
      let result = content()
      return HTTPResponse(result.0, content: result.1)
    })
  }
}
