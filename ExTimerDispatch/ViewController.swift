//
//  ViewController.swift
//  ExTimerDispatch
//
//  Created by 김종권 on 2021/11/23.
//

import UIKit

class ViewController: UIViewController {
    
    private let repeatingSecondsTimer: RepeatingSecondsTimer
    
    lazy var countDownDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        return picker
    }()
    
    lazy var buttonContainerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    
    lazy var startRepeatTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("타이머 시작", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(didTapRepeatTimerButton), for: .touchUpInside)
        return button
    }()
    
    lazy var resumeRepeatTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("타이머 재개", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(didTapResumeRepeatTimerButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var suspendTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("일시정지", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(didTapSuspendTimerButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var cancelTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(didTapCancelTimerButton), for: .touchUpInside)
        return button
    }()
    
    lazy var countDownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    init(repeatingSecondsTimer: RepeatingSecondsTimer) {
        self.repeatingSecondsTimer = repeatingSecondsTimer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addSubviews()
        setupLayout()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        view.addSubview(countDownDatePicker)
        view.addSubview(buttonContainerStackView)
        buttonContainerStackView.addArrangedSubview(startRepeatTimerButton)
        buttonContainerStackView.addArrangedSubview(resumeRepeatTimerButton)
        buttonContainerStackView.addArrangedSubview(suspendTimerButton)
        buttonContainerStackView.addArrangedSubview(cancelTimerButton)
        view.addSubview(countDownLabel)
    }
    
    private func setupLayout() {
        countDownDatePicker.translatesAutoresizingMaskIntoConstraints = false
        countDownDatePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        countDownDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        buttonContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonContainerStackView.topAnchor.constraint(equalTo: countDownDatePicker.bottomAnchor, constant: 24).isActive = true
        buttonContainerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.topAnchor.constraint(equalTo: buttonContainerStackView.bottomAnchor, constant: 24).isActive = true
        countDownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func didTapRepeatTimerButton() {
        startRepeatTimer()
        setTimerButtonsUsingTimerState()
    }

    @objc func didTapResumeRepeatTimerButton() {
        repeatingSecondsTimer.resume()
        setTimerButtonsUsingTimerState()
    }
    
    var time = 0
    private func startRepeatTimer() {
        repeatingSecondsTimer.start(durationSeconds: countDownDatePicker.countDownDuration) {
            DispatchQueue.main.async {
                self.time += 1
                self.countDownLabel.text = "타이머 = \(self.time)"
            }
        } completion: {
            DispatchQueue.main.async { [weak self] in
                self?.countDownLabel.text = "타이머 완료"
            }
        }
    }
    
    @objc func didTapSuspendTimerButton() {
        repeatingSecondsTimer.suspend()
        setTimerButtonsUsingTimerState()
    }

    @objc func didTapCancelTimerButton() {
        repeatingSecondsTimer.cancel()
        setTimerButtonsUsingTimerState()
    }
    
    private func setTimerButtonsUsingTimerState() {
        
        switch repeatingSecondsTimer.timerState {
        case .resumed:
            startRepeatTimerButton.isHidden = true
            suspendTimerButton.isHidden = false
            resumeRepeatTimerButton.isHidden = true
        case .suspended:
            startRepeatTimerButton.isHidden = true
            suspendTimerButton.isHidden = true
            resumeRepeatTimerButton.isHidden = false
        case .canceled:
            startRepeatTimerButton.isHidden = false
            suspendTimerButton.isHidden = true
            resumeRepeatTimerButton.isHidden = true
            countDownLabel.text = "타이머 취소"
            time = 0
        case .finished: break
        }
    }
    
}
