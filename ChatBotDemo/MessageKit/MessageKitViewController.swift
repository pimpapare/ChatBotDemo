//
//  MessageKitViewController.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/1/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit
import Material
import MessageKit
import AVFoundation

public enum MobileCallHandlingType: Int {
    case notForwarding = 1
    case forwardingOnlyVIP = 2
    case forwardingAll = 3
    case none = 0
}

protocol MessageKitProtocol {
    
    func textResponseSuccess(text:String)
    func textResponseError()
    func prepareViewForconfirmCreateAppointment()
    func confirmCreateAppointmentState(confirm:Bool)
}

class MessageKitViewController: MessagesViewController, MessageKitProtocol {
    
    let refreshControl = UIRefreshControl()
    
    var messageList: [Message] = []
    var messageKitViewModel:MessageKitViewModel!
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var isTyping = false
    var lastestResponse:String = ""
    var createMessage:String = ""
    var callHandlingTypeText:String = ""
    
    var userInputMessage:Bool = false
    var isConfirmState:Bool = false
    
    var callHandlingType: MobileCallHandlingType?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareAppearance()
        prepareNavigationBar()
        prepareCollectionView()
        
        prepareMessageInputBar()
    }
    
    func prepareNavigationBar() {
        
        navigationItem.titleLabel.textColor = UIColor.darkGray
        navigationItem.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        navigationItem.titleLabel.adjustsFontSizeToFitWidth = true
        navigationItem.titleLabel.minimumScaleFactor = 0.6
        navigationItem.backButton.tintColor = UIColor.darkGray
        navigationItem.backButton.pulseColor = UIColor.darkGray
        navigationItem.backButton.setImage(Icon.arrowBack, for: .normal)
        navigationItem.backButton.setImage(Icon.arrowBack, for: .highlighted)
        navigationItem.backButton.setImage(Icon.arrowBack, for: .selected)
        navigationItem.backButton.setTitle(" ", for: .normal)
    }
    
    func prepareAppearance() {
        
        messageKitViewModel = MessageKitViewModel(view: self)

        let microphoneButton:InputBarButtonItem = InputBarButtonItem(frame: CGRect(x: 0, y: 0, width: 50, height: messageInputBar.frame.size.height))
        microphoneButton.setImage(Icon.cm.microphone, for: .normal)
        microphoneButton.addTarget(self, action: #selector(microphonePressed), for: .touchUpInside)
        
        var currentLeftStack = messageInputBar.leftStackViewItems
        currentLeftStack.append(microphoneButton)
        
        messageInputBar.setStackViewItems(
            currentLeftStack,forStack: InputStackView.Position.left,animated: false
        )
        
        messageInputBar.setLeftStackViewWidthConstant(to: 45, animated: false)
        
        let messagesToFetch = UserDefaults.standard.mockMessagesCount()
        
        DispatchQueue.global(qos: .userInitiated).async {
            SampleData.shared.getMessages(count: messagesToFetch) { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "ic_keyboard"),
                            style: .plain,
                            target: self,
                            action: #selector(handleKeyboardButton)),
            UIBarButtonItem(image: UIImage(named: "ic_typing"),
                            style: .plain,
                            target: self,
                            action: #selector(handleTyping))
        ]
    }
    
    @objc func microphonePressed() {
        
        print("TEST PRESS ")
    }
    
    func prepareCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: #selector(MessageKitViewController.loadMoreMessages), for: .valueChanged)
        
    }
    
    @objc func handleTyping() {
        
        defer {
            isTyping = !isTyping
        }
        
        if isTyping {
            
            messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
            messageInputBar.topStackViewPadding = .zero
            
        } else {
            
        }
    }
    
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 4) {
            SampleData.shared.getMessages(count: 10) { messages in
                DispatchQueue.main.async {
                    self.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc func handleKeyboardButton() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        let actionSheetController = UIAlertController(title: "Change Keyboard Style", message: nil, preferredStyle: .actionSheet)
        let actions = [
            UIAlertAction(title: "Slack", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.slack()
                })
            }),
            UIAlertAction(title: "iMessage", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.prepareMessageInputBar()
                })
            }),
            UIAlertAction(title: "Default", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.defaultStyle()
                })
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        actions.forEach { actionSheetController.addAction($0) }
        actionSheetController.view.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Style
    
    func slack() {
        defaultStyle()
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.layer.borderWidth = 0
        let items = [
            makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
            },
            makeButton(named: "ic_at").onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                print("@ Selected")
            },
            makeButton(named: "ic_hashtag").onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                print("# Selected")
            },
            .flexibleSpace,
            makeButton(named: "ic_library").onTextViewDidChange { button, textView in
                button.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                button.isEnabled = textView.text.isEmpty
            },
            messageInputBar.sendButton
                .configure {
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: true)
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .white
                }.onEnabled {
                    $0.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }
        ]
        items.forEach { $0.tintColor = .lightGray }
        
        // We can change the container insets if we want
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        // Since we moved the send button to the bottom stack lets set the right stack width to 0
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: true)
        
        // Finally set the items
        messageInputBar.setStackViewItems(items, forStack: .bottom, animated: true)
    }
    
    func prepareMessageInputBar() {
        
        defaultStyle()
        
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        
        let items = [
            makeButton(named: "ic_mic").onSelected {_ in
                print("clicked")
            }
        ]
        
        messageInputBar.setStackViewItems(items, forStack: .left, animated: true)
        
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 50, height: 40), animated: true)
        messageInputBar.sendButton.title = "SEND"
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.backgroundColor = .clear
        messageInputBar.textViewPadding.right = -60
        messageInputBar.textViewPadding.left = 10
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: true)
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    // MARK: - Helpers
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                self.recordAudio()
        }
    }
    
    func recordAudio() {
        
        
    }
}

extension MessageKitViewController {
    
    func setUpViewForSender(text:String) {
        
        messageInputBar.inputTextView.text = ""
        
        DispatchQueue.main.async {
            let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.lightGray])
            let message = Message(attributedText: attributedText, sender: self.currentSender(), messageId: UUID().uuidString, date: Date())
            self.messageList.append(message)
            self.messagesCollectionView.insertSections([self.messageList.count - 1])
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    func setUpViewForReceiver(text:String) {
        
        lastestResponse = text
        verifyReceiver(text: text)
        
        DispatchQueue.main.async {
            let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.lightGray])
            let message = Message(attributedText: attributedText, sender: self.currentReceiver(), messageId: UUID().uuidString, date: Date())
            self.messageList.append(message)
            self.messagesCollectionView.insertSections([self.messageList.count - 1])
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    func textResponseSuccess(text:String) {
        
        print("📲 Text Response: ",text)
        
        setUpViewForReceiver(text: text)
        speechVoice(text: text)
    }
    
    func speechVoice(text:String) {
        
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // TH-th
        
        utterance.rate = 0.5
        utterance.volume = 1
        utterance.pitchMultiplier = 1.5 // 0.5-2 Men-Women
        synth.speak(utterance)
    }
    
    func textResponseError() {
        
    }
    
    func prepareViewForconfirmCreateAppointment() {
        
        
    }
}

extension MessageKitViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return SampleData.shared.currentSender
    }
    
    func currentReceiver() -> Sender {
        return SampleData.shared.currentReceiver
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter
            }()
        }
        
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MARK: - MessagesDisplayDelegate
extension MessageKitViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
        messageInputBar.topStackViewPadding = .zero

        if isConfirmState {
            
            let items = ["no".uppercased(), "yes".uppercased()]
            let itemsSegment = UISegmentedControl(items: items)
            itemsSegment.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
            itemsSegment.selectedSegmentIndex = 3
            itemsSegment.layer.cornerRadius = 10.0
            itemsSegment.addTarget(self, action: #selector(itemsValueChanged(sender:)) , for: .valueChanged)
            
            messageInputBar.topStackView.addArrangedSubview(itemsSegment)
            
            messageInputBar.topStackViewPadding.top = 20
            messageInputBar.topStackViewPadding.left = 20
            messageInputBar.topStackViewPadding.right = 20
            messageInputBar.topStackViewPadding.bottom = 20

            messageInputBar.backgroundColor = messageInputBar.backgroundView.backgroundColor
            
        }
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    @objc func itemsValueChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            messageKitViewModel.clearDataForCreateDefaultAppointment()
        case 1:
            setUpViewForReceiver(text: "Give me a second..")
            messageKitViewModel.prepareAppointmentDataForCreateDefaultAppointment()
        default:
            print(" ")
        }
        
        isConfirmState = false
        messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
        messageInputBar.topStackViewPadding = .zero
    }
    
    func confirmCreateAppointmentState(confirm:Bool){
        isConfirmState = confirm
    }
    
    @objc func confirmCreateAppointment(sender: UIButton!) {
        
        print("Confirm")
    }
    
    @objc func cancelCreateAppointment(sender: UIButton!) {
        
        print("Cancel")
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }
    
    // MARK: - Location Messages
    
    //    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
    //        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
    //        let pinImage = #imageLiteral(resourceName: "pin")
    //        annotationView.image = pinImage
    //        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
    //        return annotationView
    //    }
    
    //    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
    //        return { view in
    //            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
    //            view.alpha = 0.0
    //            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
    //                view.layer.transform = CATransform3DIdentity
    //                view.alpha = 1.0
    //            }, completion: nil)
    //        }
    //    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        return LocationMessageSnapshotOptions()
    }
}

// MARK: - MessagesLayoutDelegate

extension MessageKitViewController: MessagesLayoutDelegate {
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .natural, vertical: .messageBottom)
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }

    // MARK: - Location Messages
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
}

// MARK: - MessageCellDelegate

extension MessageKitViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {

        print("Message tapped")
    }
    
    func didTapTopLabel(in cell: MessageCollectionViewCell) {
        print("Top label tapped")
    }
    
    func didTapBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
}

// MARK: - MessageLabelDelegate

extension MessageKitViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String : String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
}

// MARK: - MessageInputBarDelegate

extension MessageKitViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
    
        isTyping = false
        handleTyping()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        messageKitViewModel.sendTextRequest(text: text)
        setUpViewForSender(text: text)
        
        /*
         // Each NSTextAttachment that contains an image will count as one empty character in the text: String
         
         for component in inputBar.inputTextView.components {
         
         if let image = component as? UIImage {
         
         let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
         messageList.append(imageMessage)
         messagesCollectionView.insertSections([messageList.count - 1])
         
         } else if let text = component as? String {
         
         let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
         
         let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
         messageList.append(message)
         messagesCollectionView.insertSections([messageList.count - 1])
         }
         
         }
         
         inputBar.inputTextView.text = String()
         messagesCollectionView.scrollToBottom()
         */
    }
    
    func verifyReceiver(text:String) {
        
    }
    
    func verifyResponse(text:String) {
        messageKitViewModel.sendTextRequest(text: text)
    }
}
