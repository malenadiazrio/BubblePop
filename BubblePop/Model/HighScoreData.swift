//
//  HighScoreData.swift
//  BubblePop
//
//  Created by Malena Diaz Rio on 23/4/23.
//

import Foundation
import UIKit

enum DataAccesError: LocalizedError {
    //class to store errors when accessing the data. Useful when extended to a program with a database.
    case UserDoesNotExists
    case NoDataRegistered
    case SaveDataError
    case Unkown

    public var localizedDescription: String {
        switch self {
        case .UserDoesNotExists:
            return "User does not exist"
        case .NoDataRegistered:
            return "No high score data available"
        case .SaveDataError:
            return "Error ocurred trying to save the data"
        case .Unkown:
            return "Unkown error while data handling"
        }
    }
}

struct HighScoreUser: Codable {
    //class to store the information of the high score of each user.
    // It will be useful specially if we want to add a database to the program.
    var name = ""
    var classicScore = 0
    var expertScore = 0
    var lastUsedDate: Date

    init(name: String) {
        self.name = name
        lastUsedDate = Date.now
    }

    func getScore (mode: GameMode) -> Int {
        switch(mode) {
        case .classic:
            return classicScore
        case .expert:
            return expertScore
        }
    }

    mutating func setScore(_ score: Int, mode: GameMode) {
        switch(mode) {
        case .classic:
            classicScore = score
        case .expert:
            expertScore = score
        }
    }
}

class HighScoreData {

    let defaults = UserDefaults.standard

    var highScores: [HighScoreUser] = [HighScoreUser(name: "Juan")]

    init() {
        highScores = getAllUsers() //load high scores from user defaults
    }

    func saveData() throws {
        //save the information to user defaults
        do {
            let encoded = try JSONEncoder().encode(highScores) //it has to be encoded to a json
            defaults.set(encoded, forKey: "highScoreUsers")
        }
        catch {
            throw DataAccesError.SaveDataError
        }

    }

    func getAllUsers() -> [HighScoreUser] {
        //load high scores from user defaults
        if let data = UserDefaults.standard.object(forKey: "highScoreUsers") as? Data,
            let users = try? JSONDecoder().decode([HighScoreUser].self, from: data) {
            return users
        }
        return [HighScoreUser]()
    }

    func getUser(name: String) throws -> Int {
        //get the first user with that name
        if let user = highScores.firstIndex(where: { $0.name == name }) {
            return user
        }
        throw DataAccesError.UserDoesNotExists
    }

    func createUser (name: String) throws {
        //create a new user
        let newUser = HighScoreUser(name: name)
        highScores.append(newUser)
        try saveData()
    }

    func updateUserHighScore(name: String, score: Int, mode: GameMode) throws {
        //update the information of a user
        highScores = getAllUsers()
        let user = try getUser(name: name)
        guard highScores[user].getScore(mode: mode) < score else {
            return
        }
        highScores[user].setScore(score, mode: mode)
        try saveData()
    }

    func isPastUser(name: String) -> Bool {
        //check if the user exists
        return !highScores.allSatisfy({ $0.name != name })
    }

    func storeUser(name: String) throws {
        //called before the start of the game.
        if isPastUser(name: name) { // Checks if the user already exists. If it does it updates the last played date.
            let user = try! getUser(name: name)
            highScores[user].lastUsedDate = Date.now
            return
        }
        try createUser(name: name) //if the user does not exist it will create one
    }

    func getHighestScore(mode: GameMode) -> Int { //get the highest score recorded
        highScores.sort { $0.getScore(mode: mode) > $1.getScore(mode: mode) }
        return highScores.first?.getScore(mode: mode) ?? 0
    }

    func getLastPlayer() throws -> HighScoreUser {
        //get the last player. Used in the settings view to put the name of the last player in the name label.
        highScores.sort { $0.lastUsedDate > $1.lastUsedDate }
        if let user = highScores.first {
            return user
        }
        throw DataAccesError.NoDataRegistered
    }
}



