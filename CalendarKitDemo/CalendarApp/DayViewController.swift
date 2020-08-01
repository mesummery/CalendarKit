//
//  DayViewController.swift
//  CalendarApp
//
//  Created by Saika Natsui on 2020/08/01.
//  Copyright © 2020 Richard Topchii. All rights reserved.
//

import UIKit
import CalendarKit

final class DayViewController: UIViewController, DayViewControllerProtocol {

    lazy var dayView: DayView = {
        let view = DayView()
        view.delegate = self
        view.dayContentPagerView.delegate = self
        return view
    }()

    let calendar: Calendar = {
        var customCalender = Calendar(identifier: .gregorian)
        customCalender.timeZone = TimeZone.current
        return customCalender
    }()

    override func loadView() {
        super.loadView()
        view = dayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        view.tintColor = UIColor.systemIndigo

        let sizeClass = traitCollection.horizontalSizeClass
        configureDayViewLayoutForHorizontalSizeClass(sizeClass)
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator) {
      super.willTransition(to: newCollection, with: coordinator)

        configureDayViewLayoutForHorizontalSizeClass(newCollection.horizontalSizeClass)
    }

}

extension DayViewController: DayViewDelegate {
    func dayViewDidSelectEventView(_ eventView: EventView) {

    }

    func dayViewDidLongPressEventView(_ eventView: EventView) {

    }

    func dayView(dayView: DayView, didTapTimelineAt date: Date) {

    }

    func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {

    }

    func dayViewDidBeginDragging(dayView: DayView) {

    }

    func dayView(dayView: DayView, willMoveTo date: Date) {

    }

    func dayView(dayView: DayView, didMoveTo date: Date) {

    }

    func dayView(dayView: DayView, didUpdate event: EventDescriptor) {

    }


}

extension DayViewController: DayContentPagerViewDelegate {

    func dayContentPager(dayContentPager: DayContentPagerView, willMoveTo date: Date) {
        print("DayView = \(dayContentPager) will move to: \(date)")

    }

    func dayContentPager(dayContentPager: DayContentPagerView, didMoveTo date: Date) {
        print("DayView = \(dayContentPager) did move to: \(date)")
    }

    func destination(for date: Date) -> DayContentControllerProtocol {
        return DayContentViewController.instantiate(date: date)
    }

}

class DayContentViewController: UIViewController, DayContentControllerProtocol {

    @IBOutlet weak var label: UILabel!
    var date: Date = Date()

    static func instantiate(date: Date) -> DayContentViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Content") as! DayContentViewController
        viewController.date = date
        return viewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.timeZone = .current
        label.text = formatter.string(from: date)
    }
}
