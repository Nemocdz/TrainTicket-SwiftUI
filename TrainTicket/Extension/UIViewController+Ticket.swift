//
//  UIViewController+Ticket.swift
//  TrainTicket
//
//  Created by 杨子曦 on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.


import UIKit

extension UIViewController{
    fileprivate static func findBestViewController(_ vc:UIViewController) -> UIViewController! {
        if((vc.presentedViewController) != nil){
            return UIViewController.findBestViewController(vc.presentedViewController!)
        }

        else if(vc.isKind(of: UISplitViewController.classForCoder())){
            let splite = vc as! UISplitViewController
            if(splite.viewControllers.count > 0){
                return UIViewController.findBestViewController(splite.viewControllers.last!)
            }

            else{
                return vc
            }
        }

        else if(vc.isKind(of:UINavigationController.classForCoder())){
            let svc = vc as! UINavigationController
            if(svc.viewControllers.count > 0){
                return UIViewController.findBestViewController(svc.topViewController!)
            }
            else{
                return vc
            }
        }

        else if(vc.isKind(of:UITabBarController.classForCoder())){
            if let svc = vc as? UITabBarController,let v = svc.viewControllers , v.count > 0{
                return UIViewController.findBestViewController(svc.selectedViewController!)

            } else{
                return vc
            }
        }

        else{
            return vc
        }
    }

    static func currentViewController() -> UIViewController {
        let vc:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
        return UIViewController.findBestViewController(vc)
    }
}
