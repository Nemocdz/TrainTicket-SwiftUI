//
//  ViewController.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit

class ViewController: UIViewController {
    var sectionData = [["CardA","CardB","CardC"]]
    var cardCollection: TicketCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        cardCollection.register(Ticket.self, forCellWithReuseIdentifier: "CardA")
        if let layout = cardCollection.collectionViewLayout as? CustonTicketLayout {
            layout.titleHeight = 100.0
            layout.bottomShowCount = 3
            layout.cardHeight = 300
            layout.showStyle = .cover
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionData.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionData[section].count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.card(collectionView: collectionView, cellForItemAt: indexPath)
    }

    fileprivate func card(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let idenTifier = sectionData[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idenTifier, for: indexPath)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
