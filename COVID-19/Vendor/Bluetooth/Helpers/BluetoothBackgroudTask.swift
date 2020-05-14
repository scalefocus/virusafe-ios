import Foundation
import BackgroundTasks
import UIKit

class BluetoothBackgroundTask {

    /// Pending background tasks
    var backgroundTaskIDs: [String: UIBackgroundTaskIdentifier] = [:]

    init() {
        if #available(iOS 13.0, *) {
            self.cancel()
            self.registerProcessingTask()
        }
    }

    func start(taskName: String) {
        self.stop(taskName: taskName)
        let taskId = UIApplication.shared.beginBackgroundTask(
        withName: Constants.Bluetooth.BackgroundTaskID) { [weak self] in
            self?.stop(taskName: taskName)
        }
        self.backgroundTaskIDs[taskName] = taskId
        print("Background task \(taskName) started with id: \(taskId.rawValue)")
    }

    func stop(taskName: String) {
        if let taskId = self.backgroundTaskIDs[taskName] {
            print("Background task \(taskName) stopped with id: \(taskId.rawValue)")
            UIApplication.shared.endBackgroundTask(taskId)
            self.backgroundTaskIDs.removeValue(forKey: taskName)
        }
    }

    func schedule() {
        print("Scheduling background task")
        // On iOS 13 schedule long running processing task.
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.getPendingTaskRequests { requests in
                let pendingRequest = requests.first { $0.identifier == Constants.Bluetooth.BackgroundTaskID }
                if pendingRequest != nil {
                    print("Processing task is already scheduled")
                    return
                }

                print("Scheduling processing task")
                let taskRequest = BGProcessingTaskRequest.init(identifier: Constants.Bluetooth.BackgroundTaskID)
                taskRequest.requiresExternalPower = false
                taskRequest.requiresNetworkConnectivity = false
                taskRequest.earliestBeginDate =
                    Date(timeIntervalSinceNow: Constants.Bluetooth.BackgroundTaskEarliestBeginDate)

                do {
                    try BGTaskScheduler.shared.submit(taskRequest)
                } catch {
                    print("Failed to schedule processing task \(error)")
                }
            }
        }
    }

    @available(iOS 13.0, *)
    private func registerProcessingTask() {
        print("Registering processing task")
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Constants.Bluetooth.BackgroundTaskID,
            using: DispatchQueue.main) { [weak self] task in
                print("Task launch handler executed for: \(task.identifier)")
                if let processingTask = task as? BGProcessingTask {
                    self?.processingTaskStarted(task: processingTask)
                    processingTask.expirationHandler = { [weak self] in
                        if let self = self {
                            self.processingTaskExpired(task: processingTask)
                        } else {
                            processingTask.setTaskCompleted(success: false)
                        }
                    }
                } else {
                    // Should not happen.
                    task.setTaskCompleted(success: false)
                }
        }
    }

    @available(iOS 13.0, *)
    private func processingTaskStarted(task: BGProcessingTask) {
        print("Processing task started")
        // When task started, do nothing but make sure we have registered new background task
        self.schedule()
    }

    @available(iOS 13.0, *)
    private func processingTaskExpired(task: BGProcessingTask) {
        print("Processing task expired")
        // When task is expired, we should already register a new task.
        task.setTaskCompleted(success: false)
    }

    private func cancel() {
        print("Cancelling all background tasks")
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Constants.Bluetooth.BackgroundTaskID)
        }
    }
}
