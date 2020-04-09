#  ViruSafe

ViruSafe is an application, which purpose is to help Bulgarian (maybe some other as well) government in its fight with COVID-19. The systems related with the app depend on users input about their symptoms. This way the government could have better (and more visual) representation of how disease spreads.

##  REQUIREMENTS

### PREREQUISITES

+ Mac computer
+ Xcode
+ Developer account
+ iTunes Connect account (Optional)
+ Clone the repository
+ [Cocoapods dependency manager](https://cocoapods.org/)

### PODS

+ Navigate to the folder containing the Podfile in your Terminal app.
+ Now install the pod (and any other necessary project dependencies) by executing the command: `pod install`.
+ Open *COVID-19.xcworkspace* and build.

> **NB! Steps above are necessary only if you've decided to not add Pods folder to git repository.**

### BUILD SETTINGS

Base SDK:  13.2 (latest)

### RUNTIME SETTINGS

Deployment Target:  10.0

> **NB! You can build an application with Base SDK 13.2 that runs under iOS 10. But then you have to take care to not use any function or method that is not available on iOS 10. If you do, your application will crash on iOS 10 as soon as this function is used.**

### PROVISIONING

Debug version is signed automatically. Release version uses manual signing. Both however are not opened, so you have to use your own signing, while testing.

### DEBUG

Bluetooth functionality can not be tested in the Simulator. (when ready)

### ARCHIVE

+ Select Generic iOS Device for building.
+ Build the project using `Project -> Archive`.
+ Open `Window -> Organizer` (if not already open). Choose the last build and select `Upload to App Store…`. Follow the instructions.
+ Go to ***iTunes Connect*** and submit the build for distribution on App Store or for Beta Testing.

## CONTACTS

- Scalefocus AD

------

Copyright © 2020 Scalefocus AD. All rights reserved.
