//
//  ToastView.swift
//  Toast
//
//  Created by Bastiaan Jansen on 30/06/2021.
//  Contributed by Hengyu on 03/11/2022.
//

import Foundation
import UIKit

public final class AppleToastView: UIView, ToastView {
    public struct ShadowStyle: Equatable {
        public var color: CGColor = UIColor.black.withAlphaComponent(0.08).cgColor
        public var offset: CGSize = .init(width: 0, height: 4)
        public var radius: CGFloat = 8
        public var opacity: Float = 1

        internal init() { }

        public static let standard: ShadowStyle = .init()
    }

    public struct Style: Equatable {
        public var minHeight: CGFloat = 48
        public var minWidth: CGFloat = 120
        public var backgroundColor: UIColor = .init {
            if $0.userInterfaceStyle == .dark {
                return .init(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)
            } else {
                return .init(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.00)
            }
        }
        public var shadow: ShadowStyle = .standard
        public var edgeInsets: NSDirectionalEdgeInsets = .init(top: 8, leading: 24, bottom: 8, trailing: 24)

        internal init() { }

        public static let standard: Style = .init()
    }

    public override var bounds: CGRect {
        didSet { layer.cornerRadius = bounds.height / 2 }
    }

    private let style: Style
    private let child: UIView

    private weak var toast: Toast?

    public init(child: UIView, style: Style = .standard) {
        self.child = child
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        self.style = .standard
        self.child = IconAppleToastView(content: .init(title: "PLACEHOLDER"))
        super.init(coder: coder)
        commonInit()
    }

    public func createView(for toast: Toast) {
        self.toast = toast
        guard let superview else { return }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: style.minHeight),
            widthAnchor.constraint(greaterThanOrEqualToConstant: style.minWidth),
            leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: 12),
            trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -12),
            topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant: 24),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        ])

        layoutIfNeeded()

        //setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    private func commonInit() {
        addSubview(child)
        applyStyle()
        translatesAutoresizingMaskIntoConstraints = false
        addSubviewConstraints()
    }

    private func applyStyle() {
        clipsToBounds = true
        backgroundColor = style.backgroundColor
        directionalLayoutMargins = style.edgeInsets
        layer.masksToBounds = false
        style.shadow.apply(to: layer)
    }

    private func addSubviewConstraints() {
        child.translatesAutoresizingMaskIntoConstraints = false
        // we don't constrain to `layoutMarginsGuide` since it may change
        // during its superview's transforming
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: topAnchor, constant: style.edgeInsets.top),
            child.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -style.edgeInsets.bottom),
            child.leadingAnchor.constraint(equalTo: leadingAnchor, constant: style.edgeInsets.leading),
            child.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -style.edgeInsets.trailing)
        ])
    }
}

extension AppleToastView.ShadowStyle {

    @MainActor
    public func apply(to layer: CALayer) {
        layer.shadowColor = color
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}
