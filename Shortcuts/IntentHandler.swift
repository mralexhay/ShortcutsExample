//
//  IntentHandler.swift
//  Shortcuts
//
//  Created by Alex Hay on 04/04/2020.
//  Copyright © 2020 Alex Hay. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    // When shortcuts are run, the relevant intent handler should to be returned
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is MakeUppercaseIntent:
            return MakeUppercaseIntentHandler()
        default:
            // No intents should be unhandled so we'll throw an error by default
            fatalError("No handler for this intent")
        }
    }
    
}
