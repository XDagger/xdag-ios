//
//  File.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/28.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import Foundation

public class XDAGTransaction: NSObject{
    var txHash:String!
    var type:Int!
    var amount:Decimal!
    var time:String!
    
    public init(txHash:String, txType:Int, txAmount:Decimal, txTime:String) {
        self.type = txType
        self.txHash = txHash
        self.amount = txAmount
        self.time = txTime
    }
}
