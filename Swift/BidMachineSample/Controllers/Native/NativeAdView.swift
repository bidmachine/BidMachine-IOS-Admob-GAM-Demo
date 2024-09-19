//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import BidMachine

final class NativeAdView: UIView {
    private let _titleLabel = UILabel()
    private let _descriptionLabel = UILabel()
    private let _callToActionLabel = UILabel()
    
    private lazy var callToActionView = {
        let container = UIView()
        container.backgroundColor = .lightGray
        container.addSubview(_callToActionLabel)
        container.layer.cornerRadius = 7.0
        return container
    }()

    private let _iconView = UIImageView()

    private let _mediaContainerView = UIView()
    private let _adChoiceView = {
        let label = UILabel()
        label.text = "Ad"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        
        return label
    }()

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
                _mediaContainerView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 3.0
        
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
        addSubview(callToActionView)
        addSubview(_adChoiceView)

        _titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        _descriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        _callToActionLabel.textColor = .white
    }

    func setupConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        callToActionView.translatesAutoresizingMaskIntoConstraints = false
        _iconView.translatesAutoresizingMaskIntoConstraints = false
        _callToActionLabel.translatesAutoresizingMaskIntoConstraints = false
        _adChoiceView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            _iconView.widthAnchor.constraint(equalToConstant: UIConstant.iconSide),
            _iconView.heightAnchor.constraint(equalToConstant: UIConstant.iconSide),
            
            _callToActionLabel.rightAnchor.constraint(equalTo: self.callToActionView.rightAnchor, constant: -7.0),
            _callToActionLabel.leftAnchor.constraint(equalTo: self.callToActionView.leftAnchor, constant: 7.0),
            _callToActionLabel.topAnchor.constraint(equalTo: self.callToActionView.topAnchor, constant: 5.0),
            _callToActionLabel.bottomAnchor.constraint(equalTo: self.callToActionView.bottomAnchor, constant: -5.0),
            
            callToActionView.rightAnchor.constraint(equalTo: self.topStack.rightAnchor),
            callToActionView.bottomAnchor.constraint(equalTo: self.topStack.bottomAnchor),
            
            _adChoiceView.rightAnchor.constraint(equalTo: self.topStack.rightAnchor, constant: -2.0),
            _adChoiceView.topAnchor.constraint(equalTo: self.topStack.topAnchor, constant: 2.0)
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
