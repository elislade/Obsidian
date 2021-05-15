import Foundation

// https://gist.github.com/gbitaudeau/daa4d6dc46517b450965e9c7e13706a3

protocol NumberAbbrevatable { }

extension NumberAbbrevatable {
    func formatUsingAbbrevation() -> String? {
        let num = self as! NSNumber
        let formatter = NumberFormatter()
        
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [
            (0, 1, ""),
            (1000.0, 1000.0, "K"),
            (1_000_000.0, 1_000_000.0, "M"),
            (1_000_000_000.0, 1_000_000_000.0, "B"),
            (1_000_000_000_000.0, 1_000_000_000_000.0, "T")
        ]
        
        let startValue = Double (abs(Double(truncating: num)))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        }()
        
        let value = Double(truncating: num) / abbreviation.divisor
        formatter.positiveSuffix = abbreviation.suffix
        formatter.negativeSuffix = abbreviation.suffix
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSNumber)
    }
}
