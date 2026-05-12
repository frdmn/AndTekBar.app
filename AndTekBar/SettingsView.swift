import SwiftUI

struct SettingsView: View {
    @AppStorage(Defaults.Key.mac)      private var savedMac      = Defaults.mac
    @AppStorage(Defaults.Key.endpoint) private var savedEndpoint = Defaults.endpoint

    @State private var mac      = ""
    @State private var endpoint = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                SettingsSection(title: "Device", systemImage: "desktopcomputer") {
                    SettingsField(
                        title: "MAC Address",
                        text: $mac,
                        isValid: isMacValid,
                        errorMessage: "Must be 12 hexadecimal characters (e.g. 002414B2AABB)"
                    )
                }

                SettingsSection(title: "Connection", systemImage: "server.rack") {
                    SettingsField(
                        title: "AndTek Endpoint",
                        text: $endpoint,
                        isValid: isEndpointValid,
                        errorMessage: "Must be a valid http:// or https:// URL"
                    )
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 20)

            Spacer(minLength: 0)

            footer
        }
        .frame(width: 520, height: 380)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear(perform: loadDraft)
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Link(versionString, destination: URL(string: "https://github.com/frdmn/AndTekBar.app")!)
                    .foregroundStyle(.secondary)
                    .font(.caption)

                Spacer()

                Button("Cancel") {
                    loadDraft()
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button("Save") {
                    save()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.borderedProminent)
                .disabled(!hasChanges)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }

    private var isEndpointValid: Bool {
        guard let url = URL(string: endpoint), let scheme = url.scheme, url.host != nil else { return false }
        return scheme == "http" || scheme == "https"
    }

    private var isMacValid: Bool {
        let hex = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        return mac.count == 12 && mac.unicodeScalars.allSatisfy { hex.contains($0) }
    }

    private var hasChanges: Bool {
        (mac != savedMac || endpoint != savedEndpoint) && isEndpointValid && isMacValid
    }

    private func loadDraft() {
        mac      = savedMac
        endpoint = savedEndpoint
    }

    private func save() {
        savedMac      = mac
        savedEndpoint = endpoint
    }

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        return "v\(version) (\(GitVersion.commit))"
    }
}

private struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                content
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct SettingsField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var isValid: Bool = true
    var errorMessage: LocalizedStringKey? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color(nsColor: .textBackgroundColor))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(isValid ? Color.primary.opacity(0.1) : Color.red.opacity(0.6), lineWidth: isValid ? 1 : 1.5)
                }

            if !isValid, let message = errorMessage {
                Label(message, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.85))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}
