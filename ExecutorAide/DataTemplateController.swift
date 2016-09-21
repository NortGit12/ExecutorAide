//
//  DataTemplateController.swift
//  
//
//  Created by Tim on 9/20/16.
//
//

import Foundation

struct DataTemplateController {
    
    static func initializeTemplate() {
        StageModelController.shared.create(stages: [DataTemplateController.stage1, DataTemplateController.stage2, DataTemplateController.stage3]) {
            TaskModelController.shared.create(tasks: DataTemplateController.defaultStage1Tasks, completion: { 
                SubTaskModelController.shared.create(subTasks: DataTemplateController.defaultStage1SubTasks, completion: {
                    // TODO: Add details?
                })
            })
        }
    }
    
    // MARK: - Stage 1
    
    static let stage1 = Stage(descriptor: "During this stage, prepare for the passing of the testator by collecting all necessary information.", name: "Prepare", sortValue: 0, tasks: [Task]())!
    
    static let defaultStage1Tasks: [Task] = [
        Task(name: "Get Estate Documents In Order", sortValue: 0, stage: DataTemplateController.stage1, subTasks: [SubTask]())!,
//        Task(name: "Add Executor to Accounts", sortValue: 1, stage: DataTemplateController.stage1, subTasks: DataTemplateController.AddExecutorToAccountsSubTasks)!
    ]
    
    static let defaultStage1SubTasks: [SubTask] = [
        SubTask(descriptor: "Make sure the testator has their will in order.", details: nil, name: "Will", sortValue: 0, task: DataTemplateController.defaultStage1Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Trust", sortValue: 1, task: DataTemplateController.defaultStage1Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Power of Attorney", sortValue: 2, task: DataTemplateController.defaultStage1Tasks[0])!,
        
        SubTask(descriptor: "Add yourself to the testator's financial accounts", details: nil, name: "Financial Accounts", sortValue: 0, task: DataTemplateController.defaultStage1Tasks[1])!,
        SubTask(descriptor: "Add yourself to the testator's medical accounts", details: nil, name: "Medical Accounts", sortValue: 1, task: DataTemplateController.defaultStage1Tasks[1])!,
        SubTask(descriptor: "Add yourself to the testator's business accounts", details: nil, name: "Business Accounts", sortValue: 2, task: DataTemplateController.defaultStage1Tasks[1])!
    ]
    
    // MARK: - Stage 2
    
    static let stage2 = Stage(descriptor: "Upon the death of the testator, perform the immediately necessary actions and allow yourself and others to grieve.", name: "Upon Death", sortValue: 1, tasks: [Task]())!
    
    static let defaultStage2Tasks: [Task] = [
        Task(name: "Manage Communication", sortValue: 0, stage: DataTemplateController.stage2, subTasks: DataTemplateController.CommuncationManagementSubTasks)!,
        Task(name: "Secure Assets", sortValue: 1, stage: DataTemplateController.stage2, subTasks: DataTemplateController.SecureAssetsSubTasks)!
    ]
    
    static let CommuncationManagementSubTasks: [SubTask] = [
        SubTask(descriptor: "", details: nil, name: "Notify family & close friends of the death", sortValue: 0, task: DataTemplateController.defaultStage2Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Notify authorities", sortValue: 1, task: DataTemplateController.defaultStage2Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Organize and delegate further communications (media, incoming phone calls, etc.)", sortValue: 2, task: DataTemplateController.defaultStage2Tasks[0])!
    ]
    
    static let SecureAssetsSubTasks: [SubTask] = [
        SubTask(descriptor: "Collect credit cards", details: nil, name: "Credit Cards", sortValue: 0, task: DataTemplateController.defaultStage2Tasks[1])!,
        SubTask(descriptor: "Ensure that all valuable belongings are in a secure location", details: nil, name: "Valuable Belongings", sortValue: 1, task: DataTemplateController.defaultStage2Tasks[1])!,
        SubTask(descriptor: "Secure all keys to the testator's properties", details: nil, name: "Keys", sortValue: 2, task: DataTemplateController.defaultStage2Tasks[1])!
    ]
    
    // MARK: - Stage 3
    
    static let stage3 = Stage(descriptor: "When you feel ready, begin managing the estate of the testator", name: "Estate Management", sortValue: 2, tasks: [Task]())!
}
