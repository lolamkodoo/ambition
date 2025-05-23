//
//  ORBCharacterChatBox.swift
//  Offroad-iOS
//
//  Created by 김민성 on 11/7/24.
//

import UIKit

import Lottie
import RxSwift
import RxCocoa

enum ChatBoxMode {
    /// 답장하기 버튼이 있고, 접혀 있을 때 - 캐릭터로부터 선톡이 왔을 때 사용자가 chenvron 버튼 짝수(0 포함) 번 탭했을 때
    case withReplyButtonShrinked
    /// 답장하기 버튼이 있고, 펼쳐 있을 때 - 캐릭터로부터 선톡이 왔을 때 사용자가 chenvron 버튼 홀수 번 탭했을 때
    case withReplyButtonExpanded
    /// 답장하기 버튼이 없고, 접혀 있을 때 - 캐릭터로부터 답장이 왔을 때 사용자가 chenvron 버튼 짝수(0 포함) 번 탭했을 때
    case withoutReplyButtonShrinked
    /// 답장하기 버튼이 없고, 펼쳐 있을 때 - 캐릭터로부터 답장이 왔을 때 사용자가 chevron 버튼 홀수 번 탭했을 때
    case withoutReplyButtonExpanded
    /// 로딩 중일 때 - 캐릭터가 답변 중일 때
    case loading
}

class ORBCharacterChatBox: UIControl, Shrinkable {
    
    var mode: ChatBoxMode
    var disposeBag = DisposeBag()
    
    private let modeChangingAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1)
    let shrinkingAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1)
    let characterNameLabel = UILabel()
    let messageLabel = UILabel()
    let loadingAnimationView = LottieAnimationView(name: "loading2")
    let chevronImageButton = ShrinkableButton(shrinkScale: 0.9)
    let replyButton = ShrinkableButton(shrinkScale: 0.9)
    
    lazy var messageLabelTrailingConstraintToChevronImageButton = messageLabel.trailingAnchor.constraint(
        equalTo: chevronImageButton.leadingAnchor,
        constant: -2
    )
    lazy var messageLabelTrailingConstraintToSuperview = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
    lazy var replyButtonTopConstraint = replyButton.topAnchor.constraint(
        equalTo: messageLabel.bottomAnchor,
        constant: 10
    )
    lazy var replyButtonBottomConstraint = replyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
    
    init(mode: ChatBoxMode) {
        self.mode = mode
        super.init(frame: .zero)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupAdditionalLayout(mode: mode)
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#if DevTarget
extension ORBCharacterChatBox: ORBRecommendationGradientStyle { }
#endif

extension ORBCharacterChatBox {
    
    //MARK: - Layout Func
    
    private func setupLayout() {
        characterNameLabel.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        characterNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().inset(17)
        }
        
        messageLabel.setContentHuggingPriority(.init(0), for: .horizontal)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(characterNameLabel)
            make.leading.equalTo(characterNameLabel.snp.trailing).offset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(18)
        }
        
        loadingAnimationView.snp.makeConstraints { make in
            make.centerY.equalTo(characterNameLabel)
            make.leading.equalTo(characterNameLabel.snp.trailing).offset(-10)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        chevronImageButton.snp.makeConstraints { make in
            make.centerY.equalTo(messageLabel.snp.top).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.width.equalTo(34)
            make.height.equalTo(34)
        }
        
        replyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setupAdditionalLayout(mode: ChatBoxMode) {
        switch mode {
        case .withReplyButtonShrinked:
            messageLabel.numberOfLines = 1
            messageLabelTrailingConstraintToChevronImageButton.isActive = true
            messageLabelTrailingConstraintToSuperview.isActive = false
            replyButtonTopConstraint.isActive = true
            replyButtonBottomConstraint.isActive = true
        case .withReplyButtonExpanded:
            messageLabel.numberOfLines = 3
            messageLabelTrailingConstraintToChevronImageButton.isActive = true
            messageLabelTrailingConstraintToSuperview.isActive = false
            replyButtonTopConstraint.isActive = true
            replyButtonBottomConstraint.isActive = true
        case .withoutReplyButtonShrinked:
            messageLabel.numberOfLines = 1
            messageLabelTrailingConstraintToChevronImageButton.isActive = true
            messageLabelTrailingConstraintToSuperview.isActive = false
            replyButtonTopConstraint.isActive = false
            replyButtonBottomConstraint.isActive = false
        case .withoutReplyButtonExpanded:
            messageLabel.numberOfLines = 3
            messageLabelTrailingConstraintToChevronImageButton.isActive = true
            messageLabelTrailingConstraintToSuperview.isActive = false
            replyButtonTopConstraint.isActive = false
            replyButtonBottomConstraint.isActive = false
        case .loading:
            messageLabel.numberOfLines = 1
            messageLabelTrailingConstraintToChevronImageButton.isActive = false
            messageLabelTrailingConstraintToSuperview.isActive = true
            replyButtonTopConstraint.isActive = false
            replyButtonBottomConstraint.isActive = false
        }
    }
    
    //MARK: - Private Func
    
    private func setupStyle() {
        backgroundColor = .main(.main3)
        roundCorners(cornerRadius: 14)
        layer.borderColor = UIColor.neutral(.btnInactive).cgColor
        layer.borderWidth = 1
        
        layer.shadowColor = UIColor.primary(.black).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
        layer.masksToBounds = false
        
        characterNameLabel.do { label in
            label.font = .offroad(style: .iosTextBold)
            label.textColor = .sub(.sub4)
        }
        
        messageLabel.do { label in
            label.font = .offroad(style: .iosText)
            label.textColor = .main(.main2)
            label.contentMode = .topLeft
            switch mode {
            case .withReplyButtonShrinked, .withoutReplyButtonShrinked, .loading:
                label.numberOfLines = 1
            case .withReplyButtonExpanded, .withoutReplyButtonExpanded:
                label.numberOfLines = 0
            }
        }
        
        loadingAnimationView.do { animationView in
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFit
            animationView.play()
            animationView.isHidden = true
        }
        
        chevronImageButton.do { button in
            button.setImage(.icnChatViewChevronDown, for: .normal)
            button.configureBackgroundColorWhen(normal: .clear, highlighted: .grayscale(.gray100))
        }
        
        replyButton.do { button in
            button.setTitle("답장하기", for: .normal)
            button.setTitleColor(.main(.main3), for: .normal)
            button.configureBackgroundColorWhen(normal: .main(.main2), highlighted: .main(.main2).withAlphaComponent(0.7))
            button.configureTitleFontWhen(normal: .offroad(style: .iosTextContents))
            button.configuration?.baseForegroundColor = .main(.main3)
            button.roundCorners(cornerRadius: 8)
            switch mode {
            case .withReplyButtonShrinked, .withReplyButtonExpanded: button.isHidden = false
            case .withoutReplyButtonShrinked, .withoutReplyButtonExpanded, .loading: button.isHidden = true
            }
        }
    }
    
    private func setupHierarchy() {
        addSubviews(characterNameLabel, messageLabel, loadingAnimationView, chevronImageButton, replyButton)
    }
    
    private func setupActions() {
        chevronImageButton.rx.tap.bind { [weak self] in
            guard let self else { return }
            if mode == .withReplyButtonShrinked {
                changeMode(to: .withReplyButtonExpanded, animated: true)
            } else if mode == .withReplyButtonExpanded {
                changeMode(to: .withReplyButtonShrinked, animated: true)
            } else if mode == .withoutReplyButtonShrinked {
                changeMode(to: .withoutReplyButtonExpanded, animated: true)
            } else if mode == .withoutReplyButtonExpanded {
                changeMode(to: .withoutReplyButtonShrinked, animated: true)
            }
        }.disposed(by: disposeBag)
    }
    
    //MARK: - Func
    
    func setupHiddenState(mode: ChatBoxMode) {
        switch mode {
        case .withReplyButtonShrinked:
            messageLabel.isHidden = false
            replyButton.isHidden = false
            chevronImageButton.imageView?.transform = .identity
            loadingAnimationView.isHidden = true
            loadingAnimationView.stop()
        case .withReplyButtonExpanded:
            messageLabel.isHidden = false
            replyButton.isHidden = false
            chevronImageButton.imageView?.transform = .init(rotationAngle: .pi * 0.9999)
            loadingAnimationView.isHidden = true
            loadingAnimationView.stop()
        case .withoutReplyButtonShrinked:
            messageLabel.isHidden = false
            replyButton.isHidden = true
            chevronImageButton.imageView?.transform = .identity
            loadingAnimationView.isHidden = true
            loadingAnimationView.stop()
        case .withoutReplyButtonExpanded:
            messageLabel.isHidden = false
            replyButton.isHidden = true
            chevronImageButton.imageView?.transform = .init(rotationAngle: .pi * 0.9999)
            loadingAnimationView.isHidden = true
            loadingAnimationView.stop()
        case .loading:
            messageLabel.isHidden = true
            replyButton.isHidden = true
            chevronImageButton.imageView?.transform = .identity
            loadingAnimationView.isHidden = false
            loadingAnimationView.play()
        }
    }
    
    func changeMode(to mode: ChatBoxMode, animated: Bool) {
        modeChangingAnimator.stopAnimation(true)
        self.mode = mode
        chevronImageButton.isHidden = (mode == .loading)
#if DevTarget
        if mode == .withReplyButtonExpanded || mode == .withoutReplyButtonExpanded  {
            applyGradientStyle()
        } else {
            removeGradientStyle()
        }
#endif
        
        if animated {
            modeChangingAnimator.addAnimations { [weak self] in
                guard let self else { return }
                setupHiddenState(mode: mode)
                setupAdditionalLayout(mode: mode)
                superview?.layoutIfNeeded()
            }
            modeChangingAnimator.startAnimation()
        } else {
            setupHiddenState(mode: mode)
            setupAdditionalLayout(mode: mode)
            superview?.layoutIfNeeded()
        }
    }
    
    func configureContents(character name: String, message: String, mode: ChatBoxMode, animated: Bool) {
        characterNameLabel.text = name + " :"
        messageLabel.text = message
        changeMode(to: mode, animated: animated)
    }
    
}
