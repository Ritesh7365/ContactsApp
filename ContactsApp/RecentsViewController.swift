import UIKit

struct RecentCall {
    enum CallType {
        case outgoing, incoming, missed
    }

    var id = UUID()
    var contactId: UUID
    var type: CallType
    var date = Date()
}

extension Notification.Name {
    static let recentsUpdated = Notification.Name("recentsUpdated")
}

class RecentStore {
    static let shared = RecentStore()

    var calls: [RecentCall] = [] {
        didSet {
            NotificationCenter.default.post(name: .recentsUpdated, object: nil)
        }
    }

    private init() {
        // some dummy call history
        let c = ContactStore.shared.contacts
        let now = Date()
    if c.count > 5 {
            calls = [
                RecentCall(contactId: c[2].id, type: .missed, date: now.addingTimeInterval(-60 * 20)),
        RecentCall(contactId: c[0].id, type: .outgoing, date: now.addingTimeInterval(-60 * 60 * 2)),
                RecentCall(contactId: c[5].id, type: .incoming, date: now.addingTimeInterval(-60 * 60 * 26)),
    RecentCall(contactId: c[1].id, type: .missed, date: now.addingTimeInterval(-60 * 60 * 30)),
                RecentCall(contactId: c[4].id, type: .outgoing, date: now.addingTimeInterval(-60 * 60 * 72))
            ]
        }
    }

    func add(_ contactId: UUID, type: RecentCall.CallType) {
        calls.insert(RecentCall(contactId: contactId, type: type), at: 0)
    }

func delete(_ id: UUID) {
        calls.removeAll { $0.id == id }
    }
}

class RecentsViewController: UIViewController {

    let tableView = UITableView()
    let filter = UISegmentedControl(items: ["All", "Missed"])
    let emptyLabel = UILabel()
    var items: [(call: RecentCall, contact: Contact)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recents"
    view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        filter.selectedSegmentIndex = 0
        filter.addTarget(self, action: #selector(reload), for: .valueChanged)
        navigationItem.titleView = filter
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))

tableView.dataSource = self
        tableView.delegate = self
    tableView.rowHeight = 64
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "recent")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    emptyLabel.text = "No recent calls"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        tableView.backgroundView = emptyLabel

    NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .recentsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .contactsUpdated, object: nil)
        reload()
    }

    @objc func reload() {
        var list: [(call: RecentCall, contact: Contact)] = []

        for call in RecentStore.shared.calls {
            if filter.selectedSegmentIndex == 1 && call.type != .missed {
                continue
            }
            // skip if contact was deleted
    if let c = ContactStore.shared.find(call.contactId) {
                list.append((call: call, contact: c))
            }
        }

        items = list
        tableView.reloadData()
        emptyLabel.isHidden = !items.isEmpty
    }

    @objc func clearTapped() {
        let alert = UIAlertController(title: "Clear all recents?", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            RecentStore.shared.calls = []
        })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func typeText(_ type: RecentCall.CallType) -> String {
        switch type {
        case .outgoing: return "Outgoing"
        case .incoming: return "Incoming"
case .missed: return "Missed"
        }
    }

    func iconName(_ type: RecentCall.CallType) -> String {
        switch type {
        case .outgoing: return "phone.arrow.up.right"
case .incoming: return "phone.arrow.down.left"
        case .missed: return "phone.down"
        }
    }

    // today -> 10:30 AM, yesterday -> Yesterday, older -> 15/11/26
    func timeText(_ date: Date) -> String {
let f = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            f.timeStyle = .short
        } else if Calendar.current.isDateInYesterday(date) {
return "Yesterday"
        } else {
            f.dateFormat = "dd/MM/yy"
        }
        return f.string(from: date)
    }
}

extension RecentsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
        let item = items[indexPath.row]
        let missed = item.call.type == .missed

var content = cell.defaultContentConfiguration()
        content.text = item.contact.fullName
        content.textProperties.color = missed ? .systemRed : .label
        content.secondaryText = typeText(item.call.type)
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: iconName(item.call.type))
        content.imageProperties.tintColor = missed ? .systemRed : .systemGray
        cell.contentConfiguration = content

        let timeLabel = UILabel()
        timeLabel.text = timeText(item.call.date)
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        timeLabel.sizeToFit()
        cell.accessoryView = timeLabel

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController(contactId: items[indexPath.row].contact.id)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = items[indexPath.row].call.id
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
            done(true)
            RecentStore.shared.delete(id)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

