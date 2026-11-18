import UIKit

class ContactCell: UITableViewCell {

    let avatar = UILabel()
    let nameLabel = UILabel()
    let phoneLabel = UILabel()
    let star = UIImageView(image: UIImage(systemName: "star.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel.font = .systemFont(ofSize: 17, weight: .medium)
        phoneLabel.font = .systemFont(ofSize: 14)
        phoneLabel.textColor = .secondaryLabel
        star.tintColor = .systemYellow

        let textStack = UIStackView(arrangedSubviews: [nameLabel, phoneLabel])
        textStack.axis = .vertical
    textStack.spacing = 2

        for v in [avatar, textStack, star] {
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
        }

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
avatar.widthAnchor.constraint(equalToConstant: 44),
            avatar.heightAnchor.constraint(equalToConstant: 44),

textStack.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: star.leadingAnchor, constant: -8),

        star.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            star.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            star.widthAnchor.constraint(equalToConstant: 18),
            star.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ c: Contact) {
        avatar.setAvatar(c, size: 44)
        nameLabel.text = c.fullName
        phoneLabel.text = c.phone
        star.isHidden = !c.isFavorite
    }
}
