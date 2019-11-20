//
//  UIView+Shadow.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit

extension UIView {
    func setShadow(offset:CGSize,radius:CGFloat,opacity:Float) {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
}
