//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Vlad Astahov on 29.06.2026.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    func testYesButton() {
        waitForQuestion()
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        waitForCounter("2/10")
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        waitForQuestion()
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        waitForCounter("2/10")
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        waitForQuestion()
        answerTenQuestions()

        let alert = app.alerts["Этот раунд окончен!"]
        
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        waitForQuestion()
        answerTenQuestions()
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        alert.buttons["Сыграть ещё раз"].tap()
        
        XCTAssertFalse(alert.waitForExistence(timeout: 2))
        waitForCounter("1/10")
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    private func answerTenQuestions() {
        for questionNumber in 1...10 {
            app.buttons["No"].tap()
            
            if questionNumber < 10 {
                waitForCounter("\(questionNumber + 1)/10")
            }
        }
    }
    
    private func waitForQuestion() {
        XCTAssertTrue(app.images["Poster"].waitForExistence(timeout: 10))
        waitForCounter("1/10")
    }
    
    private func waitForCounter(_ value: String) {
        let predicate = NSPredicate(format: "label == %@", value)
        expectation(for: predicate, evaluatedWith: app.staticTexts["Index"])
        waitForExpectations(timeout: 5)
    }
}
