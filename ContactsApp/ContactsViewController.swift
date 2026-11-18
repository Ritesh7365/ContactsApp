import UIKit

class ContactsViewController: UIViewController {

    let tableView = UITableView()
    let search = UISearchController(searchResultsController: nil)
    var sections: [(title: String, items: [Contact])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    title = "Contacts"
        view.backgroundColor = .systemBackground
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

    search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search"
        navigationItem.searchController = search

        tableView.dataSource = self
    tableView.delegate = self
        tableView.rowHeight = 64
    tableView.register(ContactCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .contactsUpdated, object: nil)
        reload()
    }

    @objc func reload() {
        let text = search.searchBar.text?.lowercased() ?? ""

    let list = ContactStore.shared.contacts
            .filter { text.isEmpty || $0.fullName.lowercased().contains(text) || $0.phone.contains(text) }
            .sorted { $0.fullName.lowercased() < $1.fullName.lowercased() }

        let grouped = Dictionary(grouping: list) { String($0.fullName.prefix(1)).uppercased() }
        sections = grouped.keys.sorted().map { (title: $0, items: grouped[$0]!) }
    tableView.reloadData()
    }

    @objc func addTapped() {
        let nav = UINavigationController(rootViewController: AddContactViewController())
    present(nav, animated: true)
    }

    func contact(at indexPath: IndexPath) -> Contact {
        return sections[indexPath.section].items[indexPath.row]
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.configure(contact(at: indexPath))
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.title }
    }

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController(contactId: contact(at: indexPath).id)
        navigationController?.pushViewController(vc, animated: true)
    }

    // swipe left to delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let id = contact(at: indexPath).id
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
            done(true)
        ContactStore.shared.delete(id)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    // swipe right to favorite
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var c = contact(at: indexPath)
        let fav = UIContextualAction(style: .normal, title: c.isFavorite ? "Unfavorite" : "Favorite") { _, _, done in
done(true)
            c.isFavorite.toggle()
            ContactStore.shared.save(c)
        }
        fav.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [fav])
    }
}

extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reload()
    }
}
