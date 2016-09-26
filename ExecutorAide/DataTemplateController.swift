//
//  DataTemplateController.swift
//
//
//  Created by Tim on 9/20/16.
//
//

import Foundation

struct DataTemplateController {
    
    
    static func initializeTemplate(forTestator testator: Testator, completion: @escaping () -> Void) {
        let moc = Stack.shared.managedObjectContext
        moc.performAndWait {
            
            guard let stage1 = Stage(descriptor: "During this stage, prepare for the passing of the testator by collecting all necessary information.", name: "Prepare", sortValue: 0, testator: testator) else { return }
            guard let stage2 = Stage(descriptor: "Upon the death of the testator, perform the immediately necessary actions and allow yourself and others to grieve.", name: "Upon Death", sortValue: 1, testator: testator) else { return }
            guard let stage3 = Stage(descriptor: "When you feel ready, begin managing the estate of the testator", name: "Estate Management", sortValue: 2, testator: testator) else { return }
            
            
            let defaultStage1Tasks: [Task] = [
                Task(name: "Get Estate Documents In Order", sortValue: 0, stage: stage1)!,
                Task(name: "Add Executor to Accounts", sortValue: 1, stage: stage1)!
            ]
            
            
            let defaultStage1SubTasks: [SubTask] = [
                
                SubTask(descriptor: "Make sure the testator has their will in order.", name: "Will", sortValue: 0, task: defaultStage1Tasks[0])!,
                SubTask(descriptor: "", name: "Trust", sortValue: 1, task: defaultStage1Tasks[0])!,
                SubTask(descriptor: "", name: "Power of Attorney", sortValue: 2, task: defaultStage1Tasks[0])!,
                
                SubTask(descriptor: "Add yourself to the testator's financial accounts", name: "Financial Accounts", sortValue: 0, task: defaultStage1Tasks[1])!,
                SubTask(descriptor: "Add yourself to the testator's medical accounts", name: "Medical Accounts", sortValue: 1, task: defaultStage1Tasks[1])!,
                SubTask(descriptor: "Add yourself to the testator's business accounts", name: "Business Accounts", sortValue: 2, task: defaultStage1Tasks[1])!
            ]
            
            StageModelController.shared.create(stages: [stage1, stage2, stage3], completion: {
                
                TaskModelController.shared.create(tasks: defaultStage1Tasks, completion: {

                    SubTaskModelController.shared.create(subTasks: defaultStage1SubTasks, completion: {
                        
                        completion()
                    })
                })
            })
        }
    }
    
    // MARK: - Stage 1
    
    // MARK: - Stage 2
    
    //    static let stage2 = Stage(descriptor: "Upon the death of the testator, perform the immediately necessary actions and allow yourself and others to grieve.", name: "Upon Death", sortValue: 1)!
    
    //    static let defaultStage2Tasks: [Task] = [
    //        Task(name: "Manage Communication", sortValue: 0, stage: DataTemplateController.stage2)!,
    //        Task(name: "Secure Assets", sortValue: 1, stage: DataTemplateController.stage2)!
    //    ]
    
    //    static let defaultStage2SubTasks: [SubTask] = [
    //        // Communication Management
    //        SubTask(descriptor: "", details: nil, name: "Notify family & close friends of the death", sortValue: 0, task: DataTemplateController.defaultStage2Tasks[0])!,
    //        SubTask(descriptor: "", details: nil, name: "Notify authorities", sortValue: 1, task: DataTemplateController.defaultStage2Tasks[0])!,
    //        SubTask(descriptor: "", details: nil, name: "Organize and delegate further communications (media, incoming phone calls, etc.)", sortValue: 2, task: DataTemplateController.defaultStage2Tasks[0])!,
    //
    //        // Secure assets
    //        SubTask(descriptor: "Collect credit cards", details: nil, name: "Credit Cards", sortValue: 0, task: DataTemplateController.defaultStage2Tasks[1])!,
    //        SubTask(descriptor: "Ensure that all valuable belongings are in a secure location", details: nil, name: "Valuable Belongings", sortValue: 1, task: DataTemplateController.defaultStage2Tasks[1])!,
    //        SubTask(descriptor: "Secure all keys to the testator's properties", details: nil, name: "Keys", sortValue: 2, task: DataTemplateController.defaultStage2Tasks[1])!
    //    ]
    
    // MARK: - Stage 3
    
    //    static let stage3 = Stage(descriptor: "When you feel ready, begin managing the estate of the testator", name: "Estate Management", sortValue: 2)!
}
