//
//  Copyright © 2024 Appodeal. All rights reserved.
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
