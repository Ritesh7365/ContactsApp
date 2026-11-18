import UIKit

// same screen for add and edit
class AddContactViewController: UIViewController {

    var contact: Contact?

    let firstNameField = UITextField()
let lastNameField = UITextField()
    let phoneField = UITextField()
let emailField = UITextField()
    let companyField = UITextField()

init(contact: Contact? = nil) {
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
    }

required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
        title = contact == nil ? "New Contact" : "Edit Contact"

    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action:#selector(saveTapped))

        setup(firstNameField, "First name")
        setup(lastNameField, "Last name")
        setup(phoneField, "Phone")
        setup(emailField, "Email")
        setup(companyField, "Company")
        phoneField.keyboardType = .phonePad
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none

        let stack = UIStackView(arrangedSubviews: [firstNameField, lastNameField, phoneField, emailField, companyField])
        stack.axis = .vertical
        stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        if let c = contact {
            firstNameField.text = c.firstName
            lastNameField.text = c.lastName
            phoneField.text = c.phone
            emailField.text = c.email
            companyField.text = c.company
        }
    }

    func setup(_ field: UITextField, _ placeholder: String) {
        field.placeholder = placeholder
        field.backgroundColor = .secondarySystemGroupedBackground
        field.layer.cornerRadius = 10
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    func text(_ field: UITextField) -> String {
        return field.text?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func saveTapped() {
        if text(firstNameField).isEmpty || text(phoneField).isEmpty {
            let alert = UIAlertController(title: "Name and phone are required", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        var c = contact ?? Contact(firstName: "", lastName: "", phone: "")
        c.firstName = text(firstNameField)
        c.lastName = text(lastNameField)
        c.phone = text(phoneField)
        c.email = text(emailField)
        c.company = text(companyField)

        ContactStore.shared.save(c)
        dismiss(animated: true)
    }
}
