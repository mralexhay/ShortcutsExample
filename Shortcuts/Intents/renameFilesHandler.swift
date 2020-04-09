//
//  renameFilesHandler.swift
//  Shortcuts
//
//  Created by Alex Hay on 09/04/2020.
//  Copyright © 2020 Alex Hay. All rights reserved.
//

import Intents

class RenameFilesIntentHandler: NSObject, RenameFilesIntentHandling {
    
    func resolveFiles(for intent: RenameFilesIntent, with completion: @escaping ([RenameFilesFilesResolutionResult]) -> Void) {
        // For paramters that accept multiple files, we need to pass an array of Resolution Results to the completion handler
        var resultArray = [RenameFilesFilesResolutionResult]()
        let files = intent.files ?? []
        if files.isEmpty {
            resultArray.append(RenameFilesFilesResolutionResult.unsupported(forReason: .noFiles))
        } else {
            for file in files {
                resultArray.append(RenameFilesFilesResolutionResult.success(with: file))
            }
        }
        completion(resultArray)
    }
    
    // this function will provide the drop-down list of options to choose from when tapping the "Date Format parameter in Shortcuts"
    func provideDateFormatOptions(for intent: RenameFilesIntent, with completion: @escaping ([String]?, Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let fullDate = dateFormatter.string(from: Date())
        let yearsAndMonths = String(fullDate.dropLast(3))
        let yearOnly = String(fullDate.dropLast(6))
        
        let optionsArray: [String] = [fullDate, yearsAndMonths, yearOnly]
        
        completion(optionsArray, nil)
     }

    func resolveDateFormat(for intent: RenameFilesIntent, with completion: @escaping (RenameFilesDateFormatResolutionResult) -> Void) {
        if let dateFormat = intent.dateFormat {
            completion(RenameFilesDateFormatResolutionResult.success(with: dateFormat))
        } else {
            completion(RenameFilesDateFormatResolutionResult.unsupported(forReason: .empty))
        }
    }
    
    func resolveNewCase(for intent: RenameFilesIntent, with completion: @escaping (RenameCaseResolutionResult) -> Void) {
        let newCase = intent.newCase
        completion(RenameCaseResolutionResult.success(with: newCase))
    }

    func resolvePosition(for intent: RenameFilesIntent, with completion: @escaping (RenamePositionResolutionResult) -> Void) {
        let position = intent.position
        completion(RenamePositionResolutionResult.success(with: position))
    }
    
    func resolveChangeCase(for intent: RenameFilesIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        let changeCase = intent.changeCase?.boolValue ?? false
        completion(INBooleanResolutionResult.success(with: changeCase))
    }
    
    func handle(intent: RenameFilesIntent, completion: @escaping (RenameFilesIntentResponse) -> Void) {
        let files = intent.files ?? []
        let position = intent.position
        let changeCase = intent.changeCase?.boolValue ?? false
        guard let dateFormat = intent.dateFormat else {
            // We can display errors to the user when problems occur
            completion(RenameFilesIntentResponse.failure(error: "Please choose a valid date format"))
            return
        }
        
        // The intent response expects an array of INFiles
        var outputArray = [INFile]()
        
        for file in files {
            var newName = file.filename
            
            // change the case of the filename if selected
            if changeCase {
                let newCase = intent.newCase
                switch newCase {
                case .lowercase:
                    newName = newName.lowercased()
                case .uppercase:
                    newName = newName.uppercased()
                default:
                    completion(RenameFilesIntentResponse.failure(error: "An invalid case was selected"))
                    return
                }
            }
            
            // append or prepend the selected date value
            switch position {
            case .append:
                // if appending the date, we need to split the extension from the name first
                guard let fileURL = file.fileURL else {
                    completion(RenameFilesIntentResponse.failure(error: "Couldn't get file URL of \(file.filename)"))
                    return
                }
                let filePath = fileURL.deletingPathExtension().lastPathComponent
                let nameNoExt = FileManager.default.displayName(atPath: filePath)
                let ext = fileURL.pathExtension
                newName = "\(nameNoExt)_\(dateFormat).\(ext)"
            case .prepend:
                newName = "\(dateFormat)_\(newName)"
            default:
                // We'll show an error if for some reason one of our enum values hasn't been selected
                completion(RenameFilesIntentResponse.failure(error: "An invalid position was selected"))
                return
            }
            
            // construct a new INFile with identical data and type identifier and the new file name
            let renamedFile = INFile(data: file.data, filename: newName, typeIdentifier: file.typeIdentifier)
            outputArray.append(renamedFile)
        }
        completion(RenameFilesIntentResponse.success(result: outputArray))
    }
}

