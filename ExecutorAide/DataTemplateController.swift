//
//  DataTemplateController.swift
//  
//
//  Created by Tim on 9/20/16.
//
//

import Foundation

struct DataTemplateController {
    
    // MARK: - Stage 1
    
    static let stage1 = Stage(descriptor: "During this stage, prepare for the passing of the testator by collection all necessary information.", name: "Prepare", percentComplete: 0.0, sortValue: 0, tasks: DataTemplateController.stage1Tasks, context: Stack.shared.managedObjectContext)!
    
    static let stage1Tasks: [Task] = [
        Task(name: "Get Estate Documents In Order", sortValue: 0, stage: DataTemplateController.stage1, subTasks: DataTemplateController.EstateDocsSubTasks)!,
        Task(name: "Add Executor to Accounts", sortValue: 1, stage: DataTemplateController.stage1, subTasks: DataTemplateController.AddExecutorToAccountsSubTasks)!
    ]
    
    static let EstateDocsSubTasks: [SubTask] = [
        SubTask(descriptor: "Make sure the testator has their will in order.", details: nil, name: "Will", sortValue: 0, task: DataTemplateController.stage1Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Trust", sortValue: 1, task: DataTemplateController.stage1Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Power of Attorney", sortValue: 2, task: DataTemplateController.stage1Tasks[0])!
    ]
    
    static let AddExecutorToAccountsSubTasks: [SubTask] = [
        SubTask(descriptor: "Add yourself to the testator's financial accounts", details: nil, name: "Financial Accounts", sortValue: 0, task: DataTemplateController.stage1Tasks[1])!,
        SubTask(descriptor: "Add yourself to the testator's medical accounts", details: nil, name: "Medical Accounts", sortValue: 1, task: DataTemplateController.stage1Tasks[1])!,
        SubTask(descriptor: "Add yourself to the testator's business accounts", details: nil, name: "Business Accounts", sortValue: 2, task: DataTemplateController.stage1Tasks[1])!
    ]
    
    // MARK: - Stage 2
    
    static let stage2 = Stage(descriptor: "Upon the death of the testator, perform the immediately necessary actions and allow yourself and others to grieve.", name: "Upon Death", percentComplete: 0.0, sortValue: 1, tasks: DataTemplateController.stage2Tasks, context: Stack.shared.managedObjectContext)!
    
    static let stage2Tasks: [Task] = [
        Task(name: "Manage Communication", sortValue: 0, stage: DataTemplateController.stage2, subTasks: DataTemplateController.CommuncationManagementSubTasks)!,
        Task(name: "Secure Assets", sortValue: 1, stage: DataTemplateController.stage2, subTasks: DataTemplateController.SecureAssetsSubTasks)!
    ]
    
    static let CommuncationManagementSubTasks: [SubTask] = [
        SubTask(descriptor: "", details: nil, name: "Notify family & close friends of the death", sortValue: 0, task: DataTemplateController.stage1Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Notify authorities", sortValue: 1, task: DataTemplateController.stage1Tasks[0])!,
        SubTask(descriptor: "", details: nil, name: "Organize and delegate further communications (media, incoming phone calls, etc.)", sortValue: 2, task: DataTemplateController.stage1Tasks[0])!
    ]
    
    static let SecureAssetsSubTasks: [SubTask] = [
        SubTask(descriptor: "Collect credit cards", details: nil, name: "Credit Cards", sortValue: 0, task: DataTemplateController.stage2Tasks[1])!,
        SubTask(descriptor: "Ensure that all valuable belongings are in a secure location", details: nil, name: "Valuable Belongings", sortValue: 1, task: DataTemplateController.stage2Tasks[1])!,
        SubTask(descriptor: "Secure all keys to the testator's properties", details: nil, name: "Keys", sortValue: 2, task: DataTemplateController.stage2Tasks[1])!
    ]
    
    // MARK: - Stage 3
    
    static let stage3 = Stage(descriptor: "When you feel ready, begin managing the estate of the testator", name: "Estate Management", percentComplete: 0.0, sortValue: 2, tasks: [], context: Stack.shared.managedObjectContext)!
}
