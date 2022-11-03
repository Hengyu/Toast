//
//  DefaultToastView.swift
//  Toast
//
//  Created by Bastiaan Jansen on 29/06/2021.
//  Contributed by Hengyu on 03/11/2022.
//

import Foundation
import UIKit

public final class IconAppleToastView: UIView {

    public struct Content: Equatable {
        public let image: UIImage?
        public let title: String
        public let subtitle: String?

        init(image: UIImage? = nil, title: String, subtitle: String? = nil) {
            self.image = image
            self.title = title
            self.subtitle = subtitle
        }
    }

    public var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }

    public var title: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }

    public var subtitle: String? {
        get { detailTextLabel.text }
        set {
            detailTextLabel.text = newValue
            detailTextLabel.isHidden = newValue == nil
        }
    }

    private let stackView: UIStackView = .init(frame: .zero)
    private let textStackView: UIStackView = .init(frame: .zero)
    private let imageView: UIImageView = .init(frame: .zero)
    private let textLabel: UILabel = .init(frame: .zero)
    private let detailTextLabel: UILabel = .init(frame: .zero)

    public init(content: Content) {
        super.init(frame: .init(origin: .zero, size: .init(width: 120, height: 48)))

        setupSubviews()
        setupConstraints()
        setContent(content)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill

        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit

        textStackView.axis = .vertical
        textStackView.spacing = 2
        textStackView.alignment = .center

        textLabel.font = .preferredFont(forTextStyle: .subheadline)
        textLabel.numberOfLines = 1
        textStackView.addArrangedSubview(textLabel)

        detailTextLabel.textColor = .systemGray
        detailTextLabel.font = .preferredFont(forTextStyle: .footnote)
        textStackView.addArrangedSubview(detailTextLabel)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textStackView)

        addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    public func setContent(_ content: Content) {
        image = content.image
        title = content.title
        subtitle = content.subtitle
    }
}
