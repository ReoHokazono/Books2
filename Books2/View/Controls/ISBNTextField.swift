//
//  ISBNTextField.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/13.
//

import SwiftUI

struct ISBNTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {

            @Binding var text: String
            var didBecomeFirstResponder = false

            init(text: Binding<String>) {
                _text = text
            }

            func textFieldDidChangeSelection(_ textField: UITextField) {
                text = textField.text ?? ""
            }

        }

        @Binding var text: String
        var isFirstResponder: Bool = false

        func makeUIView(context: UIViewRepresentableContext<ISBNTextField>) -> UITextField {
            let textField = UITextField(frame: .zero)
            textField.placeholder = "978 4 XXXXXXXX X"
            textField.keyboardType = .decimalPad
            let preferred = UIFont.preferredFont(forTextStyle: .body).monospaced
            textField.font = .monospacedSystemFont(ofSize: preferred.pointSize, weight: .regular)
            textField.delegate = context.coordinator
            return textField
        }

        func makeCoordinator() -> ISBNTextField.Coordinator {
            return Coordinator(text: $text)
        }

        func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<ISBNTextField>) {
            uiView.text = text
            if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
                uiView.becomeFirstResponder()
                context.coordinator.didBecomeFirstResponder = true
            }
        }
    
}

struct ISBNTextField_Previews: PreviewProvider {
    static var previews: some View {
        ISBNTextField(text: .constant("978 4"))
    }
}
