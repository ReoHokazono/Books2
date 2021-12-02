//
//  Settings.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/31.
//

import SwiftUI
import MessageUI

struct Settings: View {
    
    @Environment(\.openURL) var openURL
    @AppStorage(wrappedValue: true, UserDefaultKey.displayImages)
    var displayImages: Bool
    
    @Binding var presentedSheet: ContentView.ModalPresentedSheet?
    
    @State var mailViewPresented = false
    @State var mailaddressCopyAlertPresented = false
    
    func contactButtonTapped() {
        if MFMailComposeViewController.canSendMail() {
            mailViewPresented = true
        } else {
            mailaddressCopyAlertPresented = true
        }
    }
    
    let messageBody: String = {
        """
        
        -----------
        システム情報
        version: \(Bundle.main.version)
        build: \(Bundle.main.build)
        model: \(UIDevice.current.modelName)
        OS: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        """
    }()
    
    fileprivate func FormRow(iconSystemName: String, title: String, item: AnyView? = nil) -> some View {
        HStack {
            Image(systemName: iconSystemName)
                .width(30)
            Spacer().frame(width: 15)
            Text(title)
            if let item = item {
                item
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                FormRow(
                    iconSystemName: "photo",
                    title: "書影を表示",
                    item: AnyView(Toggle("", isOn: $displayImages).accessibilityIdentifier("photoToggle"))
                )

                NavigationLink(
                    destination: CSVExportView(),
                    label: {
                        FormRow(iconSystemName: "arrow.up.doc", title: "CSVファイルを出力")
                })

                NavigationLink(
                    destination: iCloudSettingsGuideView(),
                    label: {
                        FormRow(iconSystemName: "icloud", title: "iCloud同期")
                })

                Button(action: {
                    contactButtonTapped()
                }, label: {
                    FormRow(iconSystemName: "envelope", title: "問い合わせ")
                })
                .foregroundColor(.primary)
                
                Button(action: {
                    guard let url = URL(string: "itms-apps://itunes.apple.com/us/app/booknote/id1546487927?action=write-review") else {
                        return
                    }
                    openURL(url)
                    
                }, label: {
                    FormRow(iconSystemName: "star.circle", title: "App Storeで評価")
                })
                .foregroundColor(.primary)
                
                NavigationLink(
                    destination: AcknowledgmentsList(),
                    label: {
                        FormRow(iconSystemName: "doc.append", title: "謝辞")
                    })
                
                NavigationLink(
                    destination: AboutView(),
                    label: {
                        FormRow(iconSystemName: "info.circle", title: "このアプリについて")
                    })

            }
            .navigationTitle("設定")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentedSheet = nil
                    } label: {
                        Text("完了")
                            .bold()
                    }

                }
            })
            
            .sheet(isPresented: $mailViewPresented, content: {
                MailView(
                    mailViewPresented: $mailViewPresented,
                    subject: "BookNote: Feedback",
                    recipient: "hokazono.reo@gmail.com",
                    messageBody: messageBody)
            })
            .alert(isPresented: $mailaddressCopyAlertPresented, content: {
                Alert(title: Text("メールアドレスをコピー"), primaryButton: .default(Text("コピー"), action: {
                    UIPasteboard.general.string = "hokazono.reo@gmail.com"
                }), secondaryButton: .cancel())
            })
        }
    }
    
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(presentedSheet: .constant(.settings))
    }
}
