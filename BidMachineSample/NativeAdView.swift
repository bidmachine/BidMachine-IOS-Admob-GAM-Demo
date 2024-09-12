//
//  NativeAdView.swift
//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import BidMachine

@objc
public class NativeAdView: UIView {
    private let _titleLabel = UILabel()
    private let _callToActionLabel = UILabel()
    private let _descriptionLabel = UILabel()

    private let _iconView = UIImageView()

    private let _mediaContainerView = UIView()
    private let _adChoiceView = UIView()
    
    private lazy var contentStack = {
        let stackView = UIStackView(
            arrangedSubviews: [
                _titleLabel,
                _callToActionLabel,
                _descriptionLabel,
                _iconView,
                _mediaContainerView,
                _adChoiceView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 3.0
        
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentStack)
        
        _titleLabel.text = "Title"
        _callToActionLabel.text = "Call"
        _descriptionLabel.text = "Description"

        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension NativeAdView {
    func setupConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        _iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            _iconView.widthAnchor.constraint(equalToConstant: 50),
            _iconView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

extension NativeAdView: BidMachineNativeAdRendering {
    public var titleLabel: UILabel? {
        _titleLabel
    }
    
    public var callToActionLabel: UILabel? {
        _callToActionLabel
    }
    
    public var descriptionLabel: UILabel? {
        _descriptionLabel
    }
    
    public var iconView: UIImageView? {
        _iconView
    }
    
    public var mediaContainerView: UIView? {
        _mediaContainerView
    }
    
    public var adChoiceView: UIView? {
        _adChoiceView
    }
}
