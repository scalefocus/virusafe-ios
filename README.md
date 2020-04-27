#  ViruSafe for iOS

ViruSafe aims to help the fight with COVID-19 by offering people to share their symptoms as well track the spread of COVID-19 with an interactive map, that shows how the infection has spread throughout Bulgaria.

The ViruSafe mobile app provides access to the following:
- Receiving up-to-date information regarding COVID-19
- Regular sharing of symptoms
- Sharing your location, in order to compare your location to all users who have developed symptoms
- Option to be warned if you have been in close proximity to other symptomatic users
- Option to receive location-based notifications and alerts

<a href="https://apps.apple.com/bg/app/virusafe/id1506362170?mt=8"><img alt='Download on the App Store' src='https://linkmaker.itunes.apple.com/en-gb/badge-lrg.svg?releaseDate=2020-04-06&kind=iossoftware&bubble=ios_apps'/></a>

Overview:
- [ViruSafe for iOS](#virusafe-for-ios)
  - [Build Instructions](#build-instructions)
    - [Prerequisites](#prerequisites)
    - [Pods](#pods)
    - [Firebase](#firebase)
    - [Flex](#flex)
    - [Build Settings](#build-settings)
    - [Provisioning](#provisioning)
    - [Debug](#debug)
    - [Archive](#archive)
  - [Code Styleguide](#code-styleguide)
  - [Using the REST API](#using-the-rest-api)
    - [Using a Mock API](#using-a-mock-api)
  - [Contributing](#contributing)
  - [Security](#security)
  - [Contacts](#contacts)
  - [License](#license)

##  Build Instructions

### Prerequisites

- Mac computer
- Xcode
- Developer account
- iTunes Connect account (Optional)
- Clone the repository
- [Cocoapods dependency manager](https://cocoapods.org/)

### Pods

- Navigate to the folder containing the Podfile in your Terminal app.
- Now install the pod (and any other necessary project dependencies) by executing the command: `pod install`.
- Open *COVID-19.xcworkspace* and build.

> **NB!  `NetworkKit`  is a Development Pod. After every change in it you have to execute `pod install` and clean build your project.**

### Firebase

In order to have working app you should add `GoogleService-Info.plist` to the project. You have to setup your own firebase project. You can have either one configuration for all targets or many (one per target). You can setup your own remote config. Check `RemoteConfigDefaults` for used keys.

> **NB! We're using Firebase for Push notifications, Remote config and Crashlytics. Also Firbase collects some Analytics like installing and reinstalling of  the app by default .**

### Flex

As you don't have Flex API key this build step will fail, but you're covered. We ship our code with default localization for every target.

### Build Settings

Base SDK:  Latest
Deployment Target:  10.0

> **NB! You can build an application with latest Base SDK that runs under iOS 10. But then you have to take care to not use any function or method that is not available on iOS 10. If you do, your application will crash on iOS 10 as soon as this function is used.**

### Provisioning

Debug version is signed automatically. Release version uses manual signing. Both however are not opened, so you have to use your own signing, while testing.

### Debug

Bluetooth functionality can not be tested in the Simulator. *(Don't worry BT is not added yet)*

## Code Styleguide

We decided to refer to [The Official raywenderlich.com Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)

Contributors are expected to read through and familiarize themselves with the style guide as we're going to enforce it adding `swiftlint`.

## Branching guide

Contributors must work directly with their private forks on GitHub. It is expected that all contributions will be submitted via a feature branch originating from the appropriate up-to-date `develop` branch. Please check our [branching strategy](GIT-BRANCHING-STRATEGY.md)

## Using the REST API

Swagger Documentation for the ViruSafe REST API is available at the [ViruSafe SwaggerHub](https://app.swaggerhub.com/apis-docs/ViruSafe/viru-safe_backend_rest_api/1.0.0).

Also, the ViruSafe Swagger API Docs are available for [download as JSON](https://api.swaggerhub.com/apis/ViruSafe/viru-safe_backend_rest_api/1.0.0) and [as YAML](https://api.swaggerhub.com/apis/ViruSafe/viru-safe_backend_rest_api/1.0.0/swagger.yaml) files. These become useful when setting up your Mock API.

### Using a Mock API

To develop the mobile app against a Mock API, please check the guidelines on how to [Use a Mock API](Using-Mock-API.md)

## Contributing

Read our [Contributing Guide](CONTRIBUTING.md) to learn about reporting issues, contributing code, and more ways to contribute.

## Security

If you happen to find a security vulnerability, we would appreciate you letting us know by contacting us on - virusafe.support (at) scalefocus.com and allowing us to respond before disclosing the issue publicly.

## Contacts

Feel free to checkout our [Slack Team](https://join.slack.com/t/virusafe/shared_invite/zt-dthph60w-KGyk_s6rjoGa6WjR7~tCAg) and join the discussion there ✌️

## License

Copyright 2020 SCALE FOCUS AD

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
