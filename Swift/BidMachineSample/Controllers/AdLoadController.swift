//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit

extension AdLoadController {
    enum State {
        case idle, loading, loaded
    }
}

class AdLoadController: UIViewController {
    var topTitle: String? {
        nil
    }
    
    let contentLayoutGuide = UILayoutGuide()

    private let loadButton = UIButton(type: .system)
    private let showButton = UIButton(type: .system)
    
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var controlsStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                loadButton,
                showButton
            ]
        )
        stackView.spacing = 8.0
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        layoutContent()
        switchState(to: .idle)
    }
    
    func layoutContent() {
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStackView)
        view.addSubview(activityIndicator)
        view.addSubview(titleLabel)
        view.addLayoutGuide(contentLayoutGuide)
        
        NSLayoutConstraint.activate([
            controlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStackView.widthAnchor.constraint(equalTo: view.widthAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5.0),

            contentLayoutGuide.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.0),
            contentLayoutGuide.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor),
            contentLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func setupSubviews() {
        view.backgroundColor = .white
        activityIndicator.hidesWhenStopped = true

        titleLabel.text = topTitle
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        loadButton.setTitle("Load Ad", for: .normal)
        loadButton.addTarget(self, action: #selector(loadAd), for: .touchUpInside)

        showButton.addTarget(self, action: #selector(showAd), for: .touchUpInside)
        showButton.setTitle("Show Ad", for: .normal)
    }
    
    final func switchState(to state: State) {
        switch state {
        case .idle:
            loadButton.isEnabled = true
            showButton.isEnabled = false
            activityIndicator.stopAnimating()

        case .loading:
            loadButton.isEnabled = false
            showButton.isEnabled = false
            activityIndicator.startAnimating()

        case .loaded:
            loadButton.isEnabled = false
            showButton.isEnabled = true
            activityIndicator.stopAnimating()
        }
    }
}

extension AdLoadController {
    final func showAlert(with text: String) {
        let controller = UIAlertController(title: "Opps", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        
        controller.addAction(okAction)
        present(controller, animated: true)
    }
}

extension AdLoadController {
    @objc
    func loadAd() {
        // no-op
    }
    
    @objc
    func showAd() {
        // no-op
    }
}

