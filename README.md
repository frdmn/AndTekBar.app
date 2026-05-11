# AndTekBar.app

| | |
|---|---|
| ![menubar](https://up.frd.mn/L67FgmZmBmgAJSHBr2ZsmycdN/Bildschirmfoto-2026-05-06-um-10.40.37.png) | ![settings](https://up.frd.mn/mJyFvqUltc7b9kLOvCENVxQFL/Bildschirmfoto-2026-05-11-um-11.26.14.png) |

Tiny menubar App for macOS to control your AndTek call center.

Caution: AndTekBar uses a new name since version 0.5.3, thus a new bundle ID. This means you need to download the application manually to obtain the latest versions. Auto updates will be disabled for the "old" application.

## Installation

1. Make sure you've installed all requirements
2. Download a prebuilt binary from [GitHub releases](https://github.com/frdmn/AndTekBar.app/releases)

## Development

Here's a short explanation how to contribute to `AndTekBar.app`:

1. Make sure you've installed all requirements
2. Clone this repository:
  `git clone https://github.com/frdmn/AndTekBar.app`
3. Compile the project:
  `xcodebuild`
4. Open the executable which can be found in:
  `${GITDIR}/build/Release/AndTekBar.app`

## MDM / Pre-deployment Configuration

Settings can be pre-seeded via `defaults write` before the app is installed or launched for the first time. MDM can run these as a script during enrollment:

```bash
defaults write mn.frd.AndTekBar endpoint "http://192.168.1.1:8080/andphone/ACDService"
defaults write mn.frd.AndTekBar mac "002414B2XXXX"
```

This creates `~/Library/Preferences/mn.frd.AndTekBar.plist` and the app picks up those values on first launch. Users can still change them later via the Settings UI.

## Contributing

1. Fork it
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request

## Requirements / Dependencies

* Cisco Unified Communications Manager
* AndTek call center
* ~~Xcode to compile~~ (only for development)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for more details.

## Version

1.0.0

## License

[MIT](LICENSE)
