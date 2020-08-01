//
//  DayViewControllerProtocol.swift
//  CalendarKit
//
//  Created by Saika Natsui on 2020/08/01.
//

import Foundation

public protocol DayViewControllerProtocol {
    var dayView: DayView { get }
    var calendar: Calendar { get }
}

public extension DayViewControllerProtocol where Self: UIViewController {

    func configureDayViewLayoutForHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
      dayView.transitionToHorizontalSizeClass(sizeClass)
    }
}
