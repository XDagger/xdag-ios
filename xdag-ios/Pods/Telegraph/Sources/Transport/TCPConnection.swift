//
//  TCPConnection.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/10/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol TCPConnection: class, Hashable {
  func open()
  func close(immediately: Bool)
}

// MARK: Equatable implementation

extension TCPConnection {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
}

// MARK: Hashable implementation

extension TCPConnection {
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
}
