//
//  String+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/10/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

extension String {
  public var base64: String {
    return utf8Data.base64EncodedString()
  }

  public var utf8Data: Data {
    return data(using: .utf8)!
  }

  public func truncate(count: Int, ellipses: Bool = true) -> String {
    if self.count < count { return self }
    return prefix(count) + (ellipses ? "..." : "")
  }
}
