//
//  Event.swift
//  Sportsfella
//
//  Created by Limbek Soma on 2020. 04. 25..
//  Copyright © 2020. Soma Limbek. All rights reserved.
//

import Foundation

struct Event {
    let id: String
    let date: Date
    let sport: Sport
    let state: State
    let venue: Venue
    let maxParticipants: Int
}

extension Event {
    enum State {
        case available
        case full
        case registered
    }
}
