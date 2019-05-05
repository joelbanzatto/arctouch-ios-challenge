import Foundation

extension String {
    func dateFormat(_ toFormat: String? = "MMM d, yyyy", _ fromFormat: String? = "yyyy-MM-dd") -> String {
        let formatterFrom = DateFormatter()
        formatterFrom.dateFormat = fromFormat

        let formatterTo = DateFormatter()
        formatterTo.dateFormat = toFormat

        if let date = formatterFrom.date(from: self) {
            return formatterTo.string(from: date)
        }
        return ""
    }
}
