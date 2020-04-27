fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios lint
```
fastlane ios lint
```
`lint` lane is used to enforce Swift style and conventions

:files - List of files to process (optional)
### ios setup
```
fastlane ios setup
```
`setup` lane is used to configure fastlane from GitHub actions
### ios compile
```
fastlane ios compile
```
`compile` is used to configure fastlane from GitHub actions
### ios deploy_develop_all
```
fastlane ios deploy_develop_all
```
`deploy_develop_all` lane is used to deploy all develop builds to App Center
### ios deploy_develop_north_macedonia
```
fastlane ios deploy_develop_north_macedonia
```
`deploy_develop_north_macedonia` lane is used to deploy North Macedonia develop build to App Center
### ios deploy_develop_bulgaria
```
fastlane ios deploy_develop_bulgaria
```
`deploy_develop_bulgaria` lane is used to deploy Bulgaria develop build to App Center
### ios deploy_production_all
```
fastlane ios deploy_production_all
```
`deploy_production_all` lane is used to deploy all production builds to App Store
### ios deploy_production_north_macedonia
```
fastlane ios deploy_production_north_macedonia
```
`deploy_production_north_macedonia` lane is used to deploy North Macedonia production build to App Store
### ios deploy_production_bulgaria
```
fastlane ios deploy_production_bulgaria
```
`deploy_production_north_macedonia` lane is used to deploy Bulgaria production build to App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
