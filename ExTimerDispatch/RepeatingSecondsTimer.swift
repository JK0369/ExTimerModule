//
//  RepeatingSecondsTimer.swift
//  ExTimerDispatch
//
//  Created by 김종권 on 2021/11/23.
//

import Foundation

enum TimerState {
    case suspended
    case resumed
    case canceled
    case finished
}

protocol RepeatingSecondsTimer {
    var timerState: TimerState { get }
    
    func start(durationSeconds: Double,
               repeatingExecution: (() -> Void)?,
               completion: (() -> Void)?)
    func resume()
    func suspend()
    func cancel()
}

final class RepeatingSecondsTimerImpl: RepeatingSecondsTimer {
    
    var timerState = TimerState.suspended
    private var repeatingExecution: (() -> Void)?
    private var completion: (() -> Void)?
    private var timers: (repeatTimer: DispatchSourceTimer?, nonRepeatTimer: DispatchSourceTimer?) = (DispatchSource.makeTimerSource(),
                                                                                                     DispatchSource.makeTimerSource())
    
    deinit {
        removeTimer()
    }
    
    func start(durationSeconds: Double,
               repeatingExecution: (() -> Void)? = nil,
               completion: (() -> Void)? = nil) {
        setTimer(durationSeconds: durationSeconds,
                 repeatingExecution: repeatingExecution,
                 completion: completion)
        
        resume()
    }
    
    func resume() {
        guard timerState == .suspended else { return }
        timerState = .resumed
        timers.repeatTimer?.resume()
        timers.nonRepeatTimer?.resume()
    }

    func suspend() {
        guard timerState == .resumed else { return }
        timerState = .suspended
        timers.repeatTimer?.suspend()
        timers.nonRepeatTimer?.suspend()
    }

    func cancel() {
        timerState = .canceled
        initTimer()
    }

    private func finish() {
        timerState = .finished
        cancel()
    }
    
    private func setTimer(durationSeconds: Double,
                          repeatingExecution: (() -> Void)? = nil,
                          completion: (() -> Void)? = nil) {
        initTimer()
        
        self.repeatingExecution = repeatingExecution
        self.completion = completion
        
        timers.repeatTimer?.schedule(deadline: .now(), repeating: 1)
        timers.repeatTimer?.setEventHandler(handler: repeatingExecution)
        
        timers.nonRepeatTimer?.schedule(deadline: .now() + durationSeconds)
        timers.nonRepeatTimer?.setEventHandler { [weak self] in
            self?.finish()
            completion?()
        }
    }
    
    private func initTimer() {
        timers.repeatTimer?.setEventHandler(handler: nil)
        timers.nonRepeatTimer?.setEventHandler(handler: nil)

        repeatingExecution = nil
        completion = nil
    }
    
    private func removeTimer() {
        // cancel()을 한번 실행하면 timer를 다시 사용할 수 없는 상태임을 주의
        timers.repeatTimer?.cancel()
        timers.nonRepeatTimer?.cancel()
        initTimer()
    }
}
