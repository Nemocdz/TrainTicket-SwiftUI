//
//  CollectionViewCalculate.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit

class CollectionViewCalculate: NSObject {

    fileprivate var sections:Int = 0
    fileprivate var sectionItemsCount = [Int:Int]()
    var totalCount = 0

    unowned let collect: UICollectionView
    init(collect: UICollectionView) {
        self.collect = collect
    }

    func isNeedUpdate() -> Bool {
        var isUpdate = false
        totalCount = 0
        if self.sections != collect.numberOfSections {
            self.sections = collect.numberOfSections
            sectionItemsCount.removeAll()
        }
        (0..<sections).forEach {
            let count = collect.numberOfItems(inSection: $0)
            if count != sectionItemsCount[$0] {
                sectionItemsCount[$0] = count
                isUpdate = true
            }
            totalCount += count
        }
        return isUpdate
    }
}

var collectionCalculate = "CollectionCalculateKey"
extension UICollectionView {
    var calculate: CollectionViewCalculate {
        set {
            objc_setAssociatedObject(self, &collectionCalculate, newValue, .OBJC_ASSOCIATION_RETAIN)
        } get {
            if let cal = objc_getAssociatedObject(self, &collectionCalculate) as? CollectionViewCalculate {
                return cal
            }
            self.calculate = CollectionViewCalculate(collect: self)
            return self.calculate
        }
    }
}
