//
//  TicketCel.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit

open class TicketCell: UICollectionViewCell {
    var collectionV:UICollectionView!
    var reloadBlock:(()->Void)?
    var customCardLayout: TicketLayoutAttributes?
    var originTouchY:CGFloat = 0.0
    var pangesture:UIPanGestureRecognizer?
    @objc func pan(rec:UIPanGestureRecognizer){
        let point = rec.location(in: collectionV)
        let shiftY:CGFloat = (point.y - originTouchY  > 0) ? point.y - originTouchY : 0
        switch rec.state {
        case .began:
            originTouchY = point.y
        case .changed:
            self.transform = CGAffineTransform.init(translationX: 0, y: shiftY)
        default:
            let isNeedReload = (shiftY > self.contentView.frame.height/3) ? true : false
            let resetY = (isNeedReload) ? self.contentView.bounds.height * 1.2 : 0
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: resetY)
            }, completion: { (finish) in
                if let reload = self.reloadBlock , isNeedReload ,finish {
                    reload()
                }
            })
        }
    }

    override open func prepareForReuse() {
        if pangesture == nil {
            pangesture = UIPanGestureRecognizer(target: self,action: #selector(TicketCell.pan(rec:)))
            pangesture!.delegate = self
            self.addGestureRecognizer(pangesture!)
        }
        self.setShadow(offset: CGSize(width: 0, height: -2), radius: 8, opacity: 0.5)
    }

    open override func awakeFromNib() {

        super.awakeFromNib()
//        if pangesture == nil {
//            pangesture = UIPanGestureRecognizer(target: self,action: #selector(TicketCell.pan(rec:)))
//            pangesture!.delegate = self
//            self.addGestureRecognizer(pangesture!)
//        }
//
//        self.setShadow(offset: CGSize(width: 0, height: -2), radius: 8, opacity: 0.5)
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
        if let layout = layoutAttributes as? TicketLayoutAttributes {
            customCardLayout = layout
        }
    }
}

extension TicketCell:UIGestureRecognizerDelegate {

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if let layout = customCardLayout , layout.isExpand  {
            return layout.isExpand
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let layout = customCardLayout , layout.isExpand  {
            return layout.isExpand
        }
        return false
    }
}
