//
//  TransactionTableViewCell.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/28.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var txHash: UILabel!
    @IBOutlet weak var txAmount: UILabel!
    @IBOutlet weak var txTime: UILabel!
    @IBOutlet weak var txTypeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(tx:XDAGTransaction) {
        txHash.text = tx.txHash
        var amountPrefix = "+"
        
        if tx.type == 1 {
            txTypeImage.image = UIImage(named: "tx-input")
            txAmount.textColor = UIColor.transactionInputColor()
        } else {
            amountPrefix = "-"
            txTypeImage.image = UIImage(named: "tx-output")
            txAmount.textColor = UIColor.transactionOnputColor()
            
        }
        txAmount.text = "\(amountPrefix)\(tx.amount!)"
        txTime.text = tx.time
        
    }
    

}
