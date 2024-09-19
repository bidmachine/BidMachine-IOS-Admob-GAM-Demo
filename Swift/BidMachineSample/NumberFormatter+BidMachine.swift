//
//  NumberFormatter+BidMachine.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import Foundation

extension NumberFormatter {
    static let bidMachinePrice = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.roundingMode = .ceiling
        formatter.positiveFormat = "0.00"

        return formatter
    }()
}
