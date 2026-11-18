import UIKit

class DetailViewController: UIViewController {

    let contactId: UUID

    let avatar = UILabel()
    let nameLabel = UILabel()
    let companyLabel = UILabel()
    let phoneLabel = UILabel()
    let emailLabel = UILabel()
    let favButton = UIButton(configuration: .tinted())

    init(contactId: UUID) {
        self.contactId = contactId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))

        setupViews()
        updateUI()

        NotificationCenter.default.addObserver(self, selector: #selector(contactsChanged), name: .contactsUpdated, object: nil)
    }

    func setupViews() {
        nameLabel.font = .boldSystemFont(ofSize: 26)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        companyLabel.textColor = .secondaryLabel

        var callConfig = UIButton.Configuration.filled()
        callConfig.title = "Call"
        callConfig.image = UIImage(systemName: "phone.fill")
        callConfig.imagePadding = 8
        let callButton = UIButton(configuration: callConfig)
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)

        favButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)

        var deleteConfig = UIButton.Configuration.plain()
        deleteConfig.title = "Delete Contact"
        deleteConfig.baseForegroundColor = .systemRed
        let deleteButton = UIButton(configuration: deleteConfig)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let card = UIStackView(arrangedSubviews: [phoneLabel, emailLabel])
        card.axis = .vertical
        card.spacing = 10
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let stack = UIStackView(arrangedSubviews: [avatar, nameLabel, companyLabel, card, callButton, favButton, deleteButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(24, after: companyLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            avatar.widthAnchor.constraint(equalToConstant: 100),
            avatar.heightAnchor.constraint(equalToConstant: 100),

            card.widthAnchor.constraint(equalTo: stack.widthAnchor),

            callButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
            callButton.heightAnchor.constraint(equalToConstant: 50),

            favButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
            favButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func updateUI() {
        guard let c = ContactStore.shared.find(contactId) else { return }

        avatar.setAvatar(c, size: 100)
        nameLabel.text = c.fullName
        companyLabel.text = c.company
        companyLabel.isHidden = c.company.isEmpty

        let email = c.email.isEmpty ? "-" : c.email
        phoneLabel.text = "Phone: \(c.phone)"
        emailLabel.text = "Email: \(email)"

        favButton.configuration?.title = c.isFavorite ? "Remove from Favorites" : "Add to Favorites"
        favButton.configuration?.image = UIImage(systemName: c.isFavorite ? "star.fill" : "star")
        favButton.configuration?.imagePadding = 8
        favButton.configuration?.baseBackgroundColor = .systemOrange
        favButton.configuration?.baseForegroundColor = .systemOrange
    }

    @objc func contactsChanged() {
        if ContactStore.shared.find(contactId) == nil {
            navigationController?.popViewController(animated: true)
        } else {
            updateUI()
        }
    }

    @objc func callTapped() {
        guard let c = ContactStore.shared.find(contactId) else { return }
        let alert = UIAlertController(title: "Calling \(c.firstName)", message: c.phone, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func favTapped() {
        guard var c = ContactStore.shared.find(contactId) else { return }
        c.isFavorite.toggle()
        ContactStore.shared.save(c)
    }

    @objc func editTapped() {
        guard let c = ContactStore.shared.find(contactId) else { return }
        let nav = UINavigationController(rootViewController: AddContactViewController(contact: c))
        present(nav, animated: true)
    }

    @objc func deleteTapped() {
        let alert = UIAlertController(title: "Delete this contact?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            ContactStore.shared.delete(self.contactId)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
