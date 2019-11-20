//
//  Ticket.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit

class Ticket: TicketCell {
    private lazy var startUp: UILabel = {
        let label = UILabel()
        label.text = start
        return label
    }()

    private lazy var destination: UILabel = {
        let label = UILabel()
        label.text = des
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = time
        return label
    }()

    private var start: String
    private var des: String
    private var time: String


    init(start: String, des: String, time: String) {
        super.init()
        self.start = start
        self.des = des
        self.time = time
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        removeFromSuperview()
    }

}
