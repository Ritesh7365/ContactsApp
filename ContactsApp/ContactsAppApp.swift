
//  ContactsAppApp.swift
//  ContactsApp
//Build by Ritesh Shinde

import SwiftUI
import UIKit

@main
struct ContactsAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .ignoresSafeArea()
        }
    }
}

struct RootView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UITabBarController {
        let contactsNav = UINavigationController(rootViewController: ContactsViewController())
        contactsNav.navigationBar.prefersLargeTitles = true
        contactsNav.tabBarItem = UITabBarItem(title: "Contacts", image: UIImage(systemName: "person.crop.circle"), tag: 0)

        let recentsNav = UINavigationController(rootViewController: RecentsViewController())
        recentsNav.tabBarItem = UITabBarItem(title: "Recents", image: UIImage(systemName: "clock.fill"), tag: 1)

        let favNav = UINavigationController(rootViewController: FavoritesViewController())
        favNav.navigationBar.prefersLargeTitles = true
        favNav.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star.fill"), tag: 2)

        let tabBar = UITabBarController()
        tabBar.viewControllers = [contactsNav, recentsNav, favNav]
        return tabBar
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
    }
}
