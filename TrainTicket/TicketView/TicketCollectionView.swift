//
//  TicketCollectionView.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit


public enum LayoutStyle {
    case card
}

class TicketCollectionView: UICollectionView {

    fileprivate var transition = CustomFlipTransition(duration: 0.5)
    fileprivate lazy var _proxyDelegate: DelegateProxy = {
        return DelegateProxy(parentObject: self)
    }()
    var layoutStyle: LayoutStyle = .card {
        didSet {
            switch layoutStyle {
            case .card:
                self.collectionViewLayout = CustonTicketLayout()

            }
        }
    }

    override public var delegate: UICollectionViewDelegate? {
        get {
            return super.delegate
        } set {
            self._proxyDelegate.forwardDelegate = newValue
            super.delegate = _proxyDelegate as! UICollectionViewDelegate
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setup()
    }

    func setup() {

        switch self.collectionViewLayout {
        case _ as CustonTicketLayout:
            self.layoutStyle = .card
        default:
            self.layoutStyle = .card
        }
    }

    override public var bounds: CGRect {
        didSet {
            if oldValue != bounds && bounds.size != .zero {
                switch self.collectionViewLayout {
                case let l as CustonTicketLayout:
                    l.updateCellSize()
                default:
                    break
                }
                self.reloadData()
            }
        }
    }

    public func presentViewController(to vc:UIViewController) {

        if (self.collectionViewLayout as? CustonTicketLayout)?.selectPath == nil {
            print ("You need select a cell")
            return
        }

        let current = UIViewController.currentViewController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        current.present(vc, animated: true, completion: nil)
    }
}


extension TicketCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? TicketCell {
            c.collectionV = collectionView
            c.reloadBlock = {
                if let custom = collectionView.collectionViewLayout as? CustonTicketLayout {
                    custom.selectPath = nil
                }
            }
            c.isHidden = false
        }
        _proxyDelegate.forwardDelegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.collectionViewLayout {
        case let l as CustonTicketLayout:
            l.selectPath = indexPath
        default:
            break
        }
        _proxyDelegate.forwardDelegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}

extension TicketCollectionView: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        if let custom = self.collectionViewLayout as? CustonTicketLayout , let path = custom.selectPath {

            transition.cardView = self.cellForItem(at: path)
            custom.isFullScreen = true
        }
        return transition
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        if let custom = self.collectionViewLayout as? CustonTicketLayout {
            custom.isFullScreen = false
        }
        return transition
    }
}
