//
//  TaskEditController.swift
//  To-Do Manager
//
//  Created by Андрей Бучевский on 06.08.2021.
//

import UIKit

class TaskEditController: UITableViewController {
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle?.text = taskText
        taskTypeLabel.text = taskTitles[taskType]
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }
    
  
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let title = taskTitle?.text ?? ""
        if title != "" {
            let type = taskType
            let status: TaskStatus = taskStatusSwitch.isOn ? .completed: .planned
            doAfterEdit?(title, type, status)
            navigationController?.popViewController(animated: true)
        } else {
            showAlert()
        }
    }
    
    private var taskTitles: [TaskPriority: String] = [
        .important: "Важная",
        .normal: "Текущая"
    ]
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            let destination = segue.destination as! TaskTypeController
            destination.selectedType = taskType
            destination.doAfterTypeSelected = {[unowned self] selectedType in
                taskType = selectedType
                taskTypeLabel?.text = taskTitles[taskType]
            }
        }
    }
    private func showAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Введите текст", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}




