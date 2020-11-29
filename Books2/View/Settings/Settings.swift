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
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Image(systemName: "photo")
                    Spacer().frame(width: 15)
                    Text("書影を表示")
                    Toggle("", isOn: $displayImages)
                }

                NavigationLink(
                    destination: CSVExportView(),
                    label: {
                        HStack {
                            Image(systemName: "arrow.up.doc")
                            Spacer().frame(width: 15)
                            Text("CSVファイルを出力")
                        }
                })

                NavigationLink(
                    destination: iCloudSettingsGuideView(),
                    label: {
                        HStack {
                            Image(systemName: "icloud")
                            Spacer().frame(width: 15)
                            Text("iCloud同期")
                        }
                })
            
                Button(action: {
                    guard let url = URL(string: "") else {
                        return
                    }
                    openURL(url)
                }, label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Spacer().frame(width: 15)
                        Text("使い方・よくある質問")
                    }
                })
                .foregroundColor(.primary)

                Button(action: {
                    contactButtonTapped()
                }, label: {
                    HStack {
                        Image(systemName: "envelope")
                        Spacer().frame(width: 15)
                        Text("問い合わせ")
                    }
                })
                .foregroundColor(.primary)
                
                Button(action: {
                    guard let url = URL(string: "itms-apps://itunes.apple.com/us/app/{sku}/id{id}?action=write-review") else {
                        return
                    }
                    openURL(url)
                    
                }, label: {
                    HStack {
                        Image(systemName: "star.circle")
                        Spacer().frame(width: 15)
                        Text("App Storeで評価")
                    }
                })
                .foregroundColor(.primary)
                
                NavigationLink(
                    destination: AcknowledgmentsList(),
                    label: {
                        HStack {
                            Image(systemName: "doc.append")
                            Spacer().frame(width: 15)
                            Text("謝辞")
                        }
                    })
                
                NavigationLink(
                    destination: AboutView(),
                    label: {
                        HStack {
                            Image(systemName: "info.circle")
                            Spacer().frame(width: 15)
                            Text("このアプリについて")
                        }
                    })

            }
            .navigationBarTitle(Text("設定"), displayMode: .inline)
            .navigationBarItems(trailing: Button("完了", action: {
                presentedSheet = nil
            }))
            .sheet(isPresented: $mailViewPresented, content: {
                MailView(
                    mailViewPresented: $mailViewPresented,
                    subject: "Keyplate: Feedback",
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
