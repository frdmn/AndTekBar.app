import SwiftUI

struct SettingsView: View {
    @AppStorage("mac")    private var savedMac    = "002414B2XXXX"
    @AppStorage("server") private var savedServer = "192.168.100.238"
    @AppStorage("port")   private var savedPort   = "8080"
    @AppStorage("api")    private var savedApi    = "andphone/ACDService"

    @State private var mac    = ""
    @State private var server = ""
    @State private var port   = ""
    @State private var api    = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Device") {
                TextField("MAC Address", text: $mac)
            }
            Section("Server") {
                TextField("Host",     text: $server)
                TextField("Port",     text: $port)
                TextField("API Path", text: $api)
            }
        }
        .frame(width: 360)
        .padding(.vertical, 16)
        .onAppear(perform: loadDraft)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Text(versionString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Cancel") { dismiss() }
                        .keyboardShortcut(.escape, modifiers: [])
                    Button("Save") { save(); dismiss() }
                        .keyboardShortcut(.return, modifiers: [])
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
    }

    private func loadDraft() {
        mac    = savedMac
        server = savedServer
        port   = savedPort
        api    = savedApi
    }

    private func save() {
        savedMac    = mac
        savedServer = server
        savedPort   = port
        savedApi    = api
    }

    private var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        return "v\(v) · © 2015–2026 by @frdmn"
    }
}
