//
//  ViewController.swift
//  FirestoreManager
//
//  Created by Limbek Soma on 2020. 05. 15..
//  Copyright © 2020. Soma Limbek. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ViewController: UIViewController {
    
    private var db = Firestore.firestore()

    @IBOutlet weak var futureEventCheckerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dbSettings = FirestoreSettings()
        dbSettings.isPersistenceEnabled = false
        dbSettings.dispatchQueue = .global(qos: .userInitiated)
        db.settings = dbSettings
        
        print(db)
    }

    @IBAction func populateDatabase(_ sender: Any) {
        populateDb()
    }
    
    @IBAction func checkForFurureEvents(_ sender: Any) {
        let futureEventsRef = db.collection("events")
            .whereField("date", isGreaterThan: Date.now)
        
        futureEventsRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                DispatchQueue.main.async {
                    if querySnapshot!.isEmpty {
                        self?.futureEventCheckerLabel.text = "No future events."
                    } else {
                        self?.futureEventCheckerLabel.text = "There are \(querySnapshot!.count) future events in the database."
                    }
                }
            }
        })
    }
    
    @IBAction func deleteFutureEvents(_ sender: Any) {
        deleteFutureEvents()
    }
    
    // MARK: - Populate database
    
    private func deleteFutureEvents() {
        let futureEventsRef = db.collection("events")
            .whereField("date", isGreaterThan: Date.now)
        
        futureEventsRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for doc in querySnapshot!.documents {
                    self?.db.collection("events").document(doc.documentID).delete()
                }
            }
        })
    }
    
    private func populateDb() {
        let batch = db.batch()
        
        let venuesAndParticipantsForSports = [
            Sport.soccer: (venue: Venue(name: "ELTE Bogdánfy utca", address: "1117 Budapest, Bogdánfy u. 10/A.", mapsLink: URL(string: "https://goo.gl/maps/iKCtNC8TXoDoWSir5")!), participants: 1),
            Sport.basketball: (venue: Venue(name: "MoM Sport", address: "1123 Budapest, Csörsz u. 14-16.", mapsLink: URL(string: "https://goo.gl/maps/Y8WJ3GzimF18ecAv6")!), participants: 1),
            Sport.volleyball: (venue: Venue(name: "ELTE Mérnök utca", address: "1119 Budapest, Mérnök utca 35.", mapsLink: URL(string: "https://goo.gl/maps/dLLyFpcLTBYoFPu27")!), participants: 1)
        ]
        let dates = generateDates()
        
        for element in venuesAndParticipantsForSports {
            let sport = element.key
            let maxParticipants = element.value.participants
            let venue = element.value.venue
            for eventDate in dates {
                let newEventRef = db.collection("events").document()
                let newEventData: [String : Any] = [
                    "date": Timestamp(date: eventDate),
                    "sport": sport.rawValue,
                    "max-participants": maxParticipants,
                    "venue-name": venue.name,
                    "venue-address": venue.address,
                    "venue-maps-link": venue.mapsLink.absoluteString,
                    "registered-users": [String]()
                ]
                batch.setData(newEventData, forDocument: newEventRef)
            }
        }
        
        batch.commit(completion: { error in
            if let error = error {
                print("\(#file) \(#function): Error writing batch \(error)")
            } else {
                print("\(#file) \(#function): Batch write succeeded")
                DispatchQueue.main.async { [weak self] in
                    self?.checkForFurureEvents(self!)
                }
            }
        })
    }
    
    private func generateDates() -> [Date] {
        var dates = [Date]()
        let destinationDay = Date.now.addingDateComponents(DateComponents(month: 3))!.month.date!
        var weekday = Date.Weekday.monday
        var day = Date.now.next(weekday)
        
        while day < destinationDay {
            let times = [
                day.at(hour: 18, minute: 0, second: 0)!,
                day.at(hour: 19, minute: 0, second: 0)!,
                day.at(hour: 20, minute: 0, second: 0)!
            ]
            dates.append(contentsOf: times)
            switch weekday {
            case .monday:
                weekday = .tuesday
            case .tuesday:
                weekday = .thursday
            case .thursday:
                weekday = .monday
            default:
                fatalError("Error generating dates.")
            }
            day = day.next(weekday)
        }
        return dates.sorted(by: { $0 < $1 })
    }
}

