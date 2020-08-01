//
//  DayContentPagerView.swift
//  CalendarKit
//
//  Created by Saika Natsui on 2020/08/01.
//

import Foundation
import DateToolsSwift

public protocol DayContentPagerViewDelegate: class {
    func dayContentPager(dayContentPager: DayContentPagerView, willMoveTo date: Date)
    func dayContentPager(dayContentPager: DayContentPagerView, didMoveTo  date: Date)
    func destination(for date: Date) -> DayContentControllerProtocol
}

public final class DayContentPagerView: UIView {

    public weak var delegate: DayContentPagerViewDelegate? {
        didSet {
            setViewController()
        }
    }

    public private(set) var calendar: Calendar = Calendar.autoupdatingCurrent

    public let pagingViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil)

    public weak var state: DayViewState? {
        willSet(newValue) {
            state?.unsubscribe(client: self)
        }
        didSet {
            state?.subscribe(client: self)
        }
    }

    public init(calendar: Calendar) {
        self.calendar = calendar
        super.init(frame: .zero)
        configure()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override public func layoutSubviews() {
      super.layoutSubviews()
      pagingViewController.view.frame = bounds
    }
}

private extension DayContentPagerView {

    func configure() {
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        addSubview(pagingViewController.view!)
    }

    func setViewController() {
        guard let controller = delegate?.destination(for: Date()) else {
            assertionFailure()
            return
        }
        pagingViewController.setViewControllers([controller], direction: .forward, animated: false, completion: nil)

    }
}

// MARK: - DayViewStateUpdating
extension DayContentPagerView: DayViewStateUpdating {

    public func move(from oldDate: Date, to newDate: Date) {
        guard let delegate = delegate else {
            assertionFailure()
            return
        }
        let oldDate = oldDate.dateOnly(calendar: calendar)
        let newDate = newDate.dateOnly(calendar: calendar)

        delegate.dayContentPager(dayContentPager: self, willMoveTo: newDate)
        let newController = delegate.destination(for: newDate)

        func completionHandler(_ completion: Bool) {
            DispatchQueue.main.async {
                // Fix for the UIPageViewController issue: https://stackoverflow.com/questions/12939280/uipageviewcontroller-navigates-to-wrong-page-with-scroll-transition-style
                self.pagingViewController.setViewControllers([newController],
                                                             direction: .reverse,
                                                             animated: false,
                                                             completion: nil)

                self.delegate?.dayContentPager(dayContentPager: self, didMoveTo: newDate)
            }
        }

        if newDate.isEarlier(than: oldDate) {
            pagingViewController.setViewControllers(
                [newController],
                direction: .reverse,
                animated: true,
                completion: completionHandler(_:))
        } else if newDate.isLater(than: oldDate) {
            pagingViewController.setViewControllers(
                [newController],
                direction: .forward,
                animated: true,
                completion: completionHandler(_:))
        }
    }
}

extension DayContentPagerView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    // MARK: - UIPageViewControllerDataSource
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let controller = viewController as? DayContentControllerProtocol else { return nil }
        let previousDate = controller.date.add(TimeChunk.dateComponents(days: -1), calendar: calendar)
        return delegate?.destination(for: previousDate)
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let controller = viewController as? DayContentControllerProtocol else { return nil }
        let nextDate = controller.date.add(TimeChunk.dateComponents(days: 1), calendar: calendar)
        return delegate?.destination(for: nextDate)
    }

    // MARK: - UIPageViewControllerDelegate
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {

        guard completed else { return }
        if let controller = pageViewController.viewControllers?.first as? DayContentControllerProtocol {
            let selectedDate = controller.date
            delegate?.dayContentPager(dayContentPager: self, willMoveTo: selectedDate)
            state?.client(client: self, didMoveTo: selectedDate)
            delegate?.dayContentPager(dayContentPager: self, didMoveTo: selectedDate)
        }
    }
}
