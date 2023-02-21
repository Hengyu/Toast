//
//  Toast.swift
//  Toast
//
//  Created by Bastiaan Jansen on 27/06/2021.
//

import UIKit

@MainActor
public final class Toast {
    private var closeTimer: Timer?

    /// This is for pan gesture to close.
    private var startY: CGFloat = 0
    private var startShiftY: CGFloat = 0

    public let view: ToastView

    public weak var delegate: ToastDelegate?

    private let configuration: ToastConfiguration

    private var initialTransform: CGAffineTransform {
        CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: -100)
    }

    /// Creates a new Toast with the default Apple style layout with an icon, title and optional subtitle.
    /// - Parameters:
    ///   - image: Image which is displayed in the toast view
    ///   - imageTint: Tint of the image
    ///   - title: Title which is displayed in the toast view
    ///   - subtitle: Optional subtitle which is displayed in the toast view
    ///   - configuration: Configuration for presentation and dismissal
    /// - Returns: A new Toast view with the configured layout
    public static func `default`(
        image: UIImage?,
        imageTint: UIColor? = .label,
        title: String,
        subtitle: String? = nil,
        configuration: ToastConfiguration = ToastConfiguration()
    ) -> Toast {
        let view = AppleToastView(
            child: IconAppleToastView(content: .init(image: image, title: title, subtitle: subtitle))
        )
        return .init(view: view, configuration: configuration)
    }

    /// Creates a new Toast with a custom view
    /// - Parameters:
    ///   - view: A view which is displayed when the toast is shown
    ///   - configuration: Configuration for presentation and dismissal
    /// - Returns: A new Toast view with the configured layout
    public static func custom(
        view: ToastView,
        configuration: ToastConfiguration = ToastConfiguration()
    ) -> Toast {
        .init(view: view, configuration: configuration)
    }

    /// Creates a new Toast with a custom view
    /// - Parameters:
    ///   - view: A view which is displayed when the toast is shown
    ///   - configuration: Configuration for presentation and dismissal
    /// - Returns: A new Toast view with the configured layout
    public required init(view: ToastView, configuration: ToastConfiguration) {
        self.view = view
        self.configuration = configuration

        view.transform = initialTransform
        view.alpha = 0
        if configuration.enablePanToClose {
            DispatchQueue.main.async {
                self.enablePanToClose()
            }
        }
    }

    /// Show the toast with haptic feedback
    /// - Parameters:
    ///   - type: Haptic feedback type
    ///   - time: Time after which the toast is shown
    public func show(haptic type: UINotificationFeedbackGenerator.FeedbackType, after time: TimeInterval = 0) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
        show(after: time)
    }

    /// Show the toast
    /// - Parameter delay: Time after which the toast is shown
    public func show(after delay: TimeInterval = 0) {
        configuration.view?.addSubview(view) ?? topController()?.view.addSubview(view)
        view.createView(for: self)

        delegate?.willShowToast(self)

        UIView.animate(
            withDuration: configuration.animationTime,
            delay: delay,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            self.view.transform = .identity
            self.view.alpha = 1
        } completion: { [self] _ in
            delegate?.didShowToast(self)
            closeTimer = Timer.scheduledTimer(
                withTimeInterval: .init(configuration.displayTime),
                repeats: false
            ) { [self] _ in
                if configuration.autoHide {
                    DispatchQueue.main.async {
                        self.close()
                    }
                }
            }
        }
    }

    /// Close the toast
    /// - Parameters:
    ///   - completion: A completion handler which is invoked after the toast is hidden
    public func close(completion: (() -> Void)? = nil) {
        delegate?.willCloseToast(self)

        UIView.animate(
            withDuration: configuration.animationTime,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction]
        ) {
            self.view.transform = self.initialTransform
            self.view.alpha = 0
        } completion: { _ in
            self.view.removeFromSuperview()
            self.view.alpha = 1
            completion?()
            self.delegate?.didCloseToast(self)
        }
    }

    private func topController() -> UIViewController? {
        if var topController = keyWindow()?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    private func keyWindow() -> UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }
            if windowScene.windows.isEmpty {
                continue
            }
            guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                continue
            }
            return window
        }
        return nil
    }
}

public extension Toast {

    @MainActor
    private func enablePanToClose() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(toastOnPan))
        view.addGestureRecognizer(pan)
    }

    @objc private func toastOnPan(_ gesture: UIPanGestureRecognizer) {
        guard let topVc = topController() else { return }

        switch gesture.state {
        case .began:
            startY = view.frame.origin.y
            startShiftY = gesture.location(in: topVc.view).y
            closeTimer?.invalidate() // prevent timer to fire close action while being touched
        case .changed:
            let delta = gesture.location(in: topVc.view).y - startShiftY
            if delta <= 0 {
                view.frame.origin.y = startY + delta
            }
        case .ended:
            let threshold = initialTransform.ty + (startY - initialTransform.ty) * 2 / 3

            if view.frame.origin.y < threshold {
                close()
            } else {
                // move back to origin position
                UIView.animate(
                    withDuration: configuration.animationTime,
                    delay: 0,
                    options: [.curveEaseOut, .allowUserInteraction]
                ) {
                    self.view.frame.origin.y = self.startY
                } completion: { [self] _ in
                    closeTimer = Timer.scheduledTimer(
                        withTimeInterval: .init(configuration.displayTime),
                        repeats: false
                    ) { [self] _ in
                        if configuration.autoHide {
                            close()
                        }
                    }
                }
            }
        default:
            break
        }
    }

    @MainActor
    func enableTapToClose() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toastOnTap))
        view.addGestureRecognizer(tap)
    }

    @objc func toastOnTap(_ gesture: UITapGestureRecognizer) {
        closeTimer?.invalidate()
        close()
    }
}
