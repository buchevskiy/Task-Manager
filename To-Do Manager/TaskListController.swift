//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Андрей Бучевский on 03.08.2021.
//

import UIKit

class TaskListController: UITableViewController {
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    var tasksStorage: TasksStorageProtocol = TasksStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func loadTasks() {
        sectionsTypesPosition.forEach{taskType in
            tasks[taskType] = []
        }
        tasksStorage.loadTasks().forEach{task in
            tasks[task.type]?.append(task)
        }
    }
    
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            for (taskGroupPriority, tasksGroup) in tasks {
                tasks[taskGroupPriority] = tasksGroup.sorted{task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            var savingArray: [TaskProtocol] = []
            tasks.forEach {_, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
    
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        sectionsTypesPosition.forEach {taskType in
            tasks[taskType] = []
        }
        tasksCollection.forEach {task in
            tasks[task.type]?.append(task)
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    //Отображение списка задач с использованием
    //прототипа со стеком и кастомным классом
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
           
            return cell
        }
    
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        guard tasks[taskType]![indexPath.row].status == .planned else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        tasks[taskType]![indexPath.row].status = .completed
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
       
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") {_, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        
        //действия для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") {_, _, _ in
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            
            editScreen.doAfterEdit = {[unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                if taskType == editedTask.type {
                    tasks[taskType]![indexPath.row] = editedTask
                } else {
                    tasks[taskType]!.remove(at: indexPath.row)
                    tasks[editedTask.type]?.append(editedTask)
                }
                tableView.reloadData()
            }
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        actionEditInstance.backgroundColor = .darkGray
        
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        
        return actionsConfiguration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

    }
    
  
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        tableView.reloadData()
    }
    
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionsTypesPosition[section]
        if tasks[tasksType]!.count == 0 {
           return nil
        }
        if tasksType == .important {
            title = "Важные"
        } else if tasksType == .normal {
            title = "Текущие"
        }
        return title
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = {[unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    
  
    
}
