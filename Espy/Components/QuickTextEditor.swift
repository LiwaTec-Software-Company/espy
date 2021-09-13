//
//  QuickInputTextField.swift
//  QuickInputTextField
//
//  Created by Willie Johnson on 9/11/21.
//

import SwiftUI
import MarkdownUI

/// First responder text field UIViewRepresentable.
struct QuickTextEditor: UIViewRepresentable {
  class Coordinator: NSObject, UITextViewDelegate {
    @Binding var text: String
    @Binding var activeFont: UIFont

    let placeholder: String?
    var becameFirstResponder = false
    let textViewOnChange: (String) -> Void

    var activeTextView: UITextView!

    var isAtBottom: Bool = false

    var textViewDidScroll: (UIScrollView) -> Void

    private var hasPlaceholderText: Bool {
      get {
        return text == placeholder
      }
    }

    private var hasTextChanged: Bool {
      get {
        return text != placeholder && becameFirstResponder
      }
    }

    init(text: Binding<String>, activeFont: Binding<UIFont>, placeholder: String?, textViewOnChange: @escaping (String) -> Void, textViewDidScroll: @escaping (UIScrollView) -> Void) {
      self._text = text
      self._activeFont = activeFont
      self.placeholder = placeholder
      self.textViewOnChange = textViewOnChange
      self.textViewDidScroll = textViewDidScroll
    }

    func textViewDidChange(_ textView: UITextView) {
      text = textView.text ?? placeholder ?? ""
      textViewOnChange(text)
      if textView.textColor == .systemGray && hasTextChanged {
        if hasPlaceholderText {
          textView.text = "# "
        }
        textView.textColor = UIColor(Color.primary)
      }
      setActive(textView: textView)
      updateViews()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
      if textView.text.isEmpty && !hasPlaceholderText {
        textView.text = placeholder
        textView.textColor = UIColor.systemGray
      }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      textViewDidScroll(scrollView)
    }

    func setActive(textView: UITextView) {
      activeTextView = textView
    }

    func updateViews() {
      activeTextView.font = activeFont
    }

  }

  @Binding var text: String
  @Binding var activeFont: UIFont

  let placeholder: String?
  let onChange: (String) -> Void
  let onScroll: (UIScrollView) -> Void

  func makeCoordinator() -> Coordinator {
    return Coordinator(text: $text, activeFont: $activeFont, placeholder: placeholder, textViewOnChange: onChange, textViewDidScroll: onScroll)
  }

  func makeUIView(context: Context) -> some UIView {
    let textView = UITextView()
    if text.count > 0 {
      textView.text = text
    } else {
      textView.text = placeholder
    }
    textView.textColor = .systemGray
    textView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 120, right: 0)
    textView.delegate = context.coordinator
    textView.font = activeFont
    context.coordinator.setActive(textView: textView)
    return textView
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    if !context.coordinator.becameFirstResponder {
      uiView.becomeFirstResponder()
      context.coordinator.becameFirstResponder = true
    }
    context.coordinator.updateViews()
  }
}
