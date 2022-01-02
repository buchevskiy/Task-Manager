//
//  SceneDelegate.swift
//  To-Do Manager
//
//  Created by Андрей Бучевский on 03.08.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        guard let window = window else {
            return
        }
        let tasks = TasksStorage().loadTasks()
        let taskListController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskListController") as! TaskListController
        taskListController.setTasks(tasks)
        let navigationController = UINavigationController(rootViewController: taskListController)
        self.window?.windowScene = windowScene
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}
