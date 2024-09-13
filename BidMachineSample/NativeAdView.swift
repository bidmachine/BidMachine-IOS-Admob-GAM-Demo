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
    private let _descriptionLabel = UILabel()
    private let _callToActionLabel = UILabel()

    private let _iconView = UIImageView()

    private let _mediaContainerView = UIView()
    private let _adChoiceView = UIView()
    
    private lazy var topStack = {
        let stackView = UIStackView(
            arrangedSubviews: [
                _iconView,
                labelsStack
            ]
        )
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 3.0
        
        return stackView
    }()
    
    private lazy var labelsStack = {
        let stackView = UIStackView(
            arrangedSubviews: [
                _titleLabel,
                _descriptionLabel,
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 3.0
        stackView.alignment = .leading
        
        return stackView
    }()
    
    private lazy var contentStack = {
        let stackView = UIStackView(
            arrangedSubviews: [
                topStack,
                _mediaContainerView,
                _adChoiceView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 3.0
        stackView.alignment = .leading
        
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension NativeAdView {
    func setupSubviews() {
        addSubview(contentStack)
        addSubview(_callToActionLabel)

        _titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        _descriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        _callToActionLabel.backgroundColor = .lightGray
    }

    func setupConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        _iconView.translatesAutoresizingMaskIntoConstraints = false
        _callToActionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            _iconView.widthAnchor.constraint(equalToConstant: UIConstant.iconSide),
            _iconView.heightAnchor.constraint(equalToConstant: UIConstant.iconSide),
            
            _callToActionLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            _callToActionLabel.bottomAnchor.constraint(equalTo: self.topStack.bottomAnchor),
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

private enum UIConstant {
    static let iconSide = 100.0
}
