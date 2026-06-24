import Foundation

private enum StatisticKeys {
    static let gamesCount = "games-count"
    static let bestCorrect = "best-correct"
    static let bestTotal = "best-total"
    static let bestDate = "best-date"
    static let totalCorrectAnswers = "total-correct-answers"
    static let totalQuestions = "total-questions"
}

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    var totalAccuracy: Double {
        if totalQuestions == 0 {
            return 0
        }
        
        return (Double(totalCorrectAnswers) / Double(totalQuestions)) * 100
    }
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(
                forKey: StatisticKeys.totalCorrectAnswers
            )
        }
        set {
            storage.set(
                newValue,
                forKey: StatisticKeys.totalCorrectAnswers
            )
        }
    }
    
    private var totalQuestions: Int {
        get {
            storage.integer(
                forKey: StatisticKeys.totalQuestions
            )
        }
        set {
            storage.set(
                newValue,
                forKey: StatisticKeys.totalQuestions
            )
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(
                forKey: StatisticKeys.gamesCount
            )
        }
        set {
            storage.set(
                newValue,
                forKey: StatisticKeys.gamesCount
            )
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(
                forKey: StatisticKeys.bestCorrect
            )
            let total = storage.integer(
                forKey: StatisticKeys.bestTotal
            )
            let date = storage.object(
                forKey: StatisticKeys.bestDate
            ) as? Date ?? Date()
            
            return GameResult(
                correct: correct,
                total: total,
                date: date
            )
        }
        set {
            storage.set(
                newValue.correct,
                forKey: StatisticKeys.bestCorrect
            )
            storage.set(
                newValue.total,
                forKey: StatisticKeys.bestTotal
            )
            storage.set(
                newValue.date,
                forKey: StatisticKeys.bestDate
            )
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        self.gamesCount += 1
        self.totalQuestions += amount
        self.totalCorrectAnswers += count
        
        let currentGame = GameResult(
            correct: count,
            total: amount,
            date: Date()
        )
        
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
