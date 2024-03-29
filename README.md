<div align="center">
  <h1>
    <br>
    <a href=""><img src="secret_share/lib/assets/images/logo.png" alt="Markdownify" width="200"></a>
    <br>
    Projets Tuteuré - Shamir's Secret Sharing Scheme
    <br>
  </h1>
</div>

<div align="center"><h4>A secret sharing Android and IOS app built on <a href="https://flutter.dev/" target="_blank">Flutter</a>.</h4></div>

<div align="center">
  <a href="#about-shamirs-secret-sharing-scheme">About SSSS</a> •
  <a href="#installation">Installation</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#features">Features</a> •
  <a href="#license">License</a>
</div>


# About Shamir's Secret Sharing Scheme

Shamir's Secret Sharing is an algorithm in cryptography created by Adi Shamir. It is a form of secret sharing, where a secret is divided into parts, giving each participant its own unique part.

To reconstruct the original secret, a minimum number of parts is required. In the threshold scheme this number is less than the total number of parts. Otherwise all participants are needed to reconstruct the original secret.

To more details : [Wiki](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing)

Demo video : [https://youtu.be/8ZmjSzKLpEw](https://youtu.be/8ZmjSzKLpEw)

## Installation

To clone and run this application, you'll need [Git](https://git-scm.com) and [Flutter](https://flutter.dev/docs/get-started/install/) installed on your computer. 

From your command line:

```bash
# Clone this repository
$ git clone https://code.up8.edu/pablo/ssss-ptut-2020-2021

# Go into the repository
$ cd secret_share

# Install dependencies
$ flutter pub get

# Run the app
$ flutter run

# If you wish to control when to use software rendering from code
$ flutter run --enable-software-rendering
```

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

## How to use

### Visual Studio Code Extension : 
- Fluter - Flutter support and debugger
- Dart - Dart language support and debugger

### Updating launcher icon :

Add your Flutter Launcher Icons configuration to your `pubspec.yaml`
```bash
dev_dependencies:
  flutter_launcher_icons: "^0.8.0"

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
```
From your command line:
```bash
# Install dependencies
$ flutter pub get

# Generate icons for android and ios
$ flutter pub run flutter_launcher_icons:main
```
In the above configuration, the package is setup to replace the existing launcher icons in both the Android and iOS project with the icon located in the image path specified above and given the name "launcher_icon" in the Android project and "Example-Icon" in the iOS project.

To more details : [Flutter docs](https://pub.dev/packages/flutter_launcher_icons)

### Build and release an Android app : 

```bash
# To build APK
$ flutter build apk

# To Build optimized APK (reduce app size)
$ flutter clean
$ flutter build appbundle --target-platform android-arm,android-arm64
```
To more details : [Flutter docs](https://flutter.dev/docs/deployment/android)

## Features

- [x] save/recover secret to folder as file
- [x] share it secret outside the app
- [ ] sharing of secrets in part(Stream)
- [x] photo implementation

## Version

```bash
Flutter_version = '1.22.6' (channel stable)
Dart_SDK_version = '2.10.5'
kotlin_version = '1.3.50'
gradle_version = '3.5.4'
```

## issue & solution

- https://github.com/miguelpruivo/flutter_file_picker/wiki/Troubleshooting#-issue-2

## Screenshots
<a href="ScreenShots/0.jpg"><img src="ScreenShots/0.jpg" alt="Markdownify" width="200"></a>
<a href="ScreenShots/1.jpg"><img src="ScreenShots/1.jpg" alt="Markdownify" width="200"></a>
<a href="ScreenShots/2.jpg"><img src="ScreenShots/2.jpg" alt="Markdownify" width="200"></a>
<a href="ScreenShots/3.jpg"><img src="ScreenShots/3.jpg" alt="Markdownify" width="200"></a>

## license

[GNU General Public License v2.0](https://github.com/pthavarasa/Secret_Sharing_App/blob/master/LICENSE)

## Contributors

@pablo , @AndyGuillaume , @pthavarasa
