import UIKit

struct Contact {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phone: String
    var email = ""
    var company = ""
    var isFavorite = false

    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        let f = firstName.first.map { String($0) } ?? ""
    let l = lastName.first.map { String($0) } ?? ""
        return (f + l).uppercased()
    }

    var color: UIColor {
        let colors: [UIColor] = [.systemBlue, .systemPink, .systemOrange, .systemGreen, .systemPurple, .systemTeal]
    let n = fullName.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[n % colors.count]
    }
}

extension Notification.Name {
    static let contactsUpdated = Notification.Name("contactsUpdated")
}

class ContactStore {
    static let shared = ContactStore()

    var contacts: [Contact] = [
        Contact(firstName: "Aarav", lastName: "Sharma", phone: "9876543210", email: "aarav@gmail.com", company: "Infosys", isFavorite: true),
        Contact(firstName: "Priya", lastName: "Patel", phone: "9123456789", email: "priya@gmail.com"),
        Contact(firstName: "Rohan", lastName: "Verma", phone: "9988776655", company: "FocalX", isFavorite: true),
        Contact(firstName: "Sneha", lastName: "Reddy", phone: "9000011122"),
        Contact(firstName: "Karan", lastName: "Mehta", phone: "9811122233", company: "Wipro"),
        Contact(firstName: "Ananya", lastName: "Iyer", phone: "9765432109", isFavorite: true),
        Contact(firstName: "Vikram", lastName: "Singh", phone: "9333344455"),
        Contact(firstName: "Neha", lastName: "Gupta", phone: "9555566677", email: "neha@gmail.com"),
        Contact(firstName: "Arjun", lastName: "Nair", phone: "9666677788", company: "FocalX"),
        Contact(firstName: "Zoya", lastName: "Khan", phone: "9888899900")
    ] {
        didSet {
            NotificationCenter.default.post(name: .contactsUpdated, object: nil)
        }
    }

    func find(_ id: UUID) -> Contact? {
        return contacts.first { $0.id == id }
    }

    func save(_ contact: Contact) {
        if let i = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[i] = contact
        } else {
            contacts.append(contact)
        }
    }

    func delete(_ id: UUID) {
        contacts.removeAll { $0.id == id }
    }
}

// round label with initials
extension UILabel {
    func setAvatar(_ c: Contact, size: CGFloat) {
        text = c.initials
        backgroundColor = c.color
textColor = .white
    textAlignment = .center
        font = .systemFont(ofSize: size * 0.4, weight: .semibold)
    layer.cornerRadius = size / 2
        clipsToBounds = true
    }
}
