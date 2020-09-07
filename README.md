[![bitrise CI](https://img.shields.io/bitrise/5c5ad1fbae41f44e?token=5fWsBdzgE3RX5yyBorWfnQ)](https://bitrise.io)
![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey)

# Travaartje

Travaartje is an iOS app to upload workouts created on AppleWatch or iPhone to Strava with one click. It's available for free on the AppStore, and the full source code is available here for anyone to look at or play with. See also https://travaartje.net.

You can use the source code to learn about various programming topics in an actual app:
* Using Swift Combine with a SwiftUI
* Integrating HealthKit related functionality into an app
* Using part of the Strava v3 API through Swift Combine
* Basic localization in SwiftUI
* How to split of functionality into separate packages (HealthKitCombine, StravaCombine)
* Separation of application logic into models
* Using CoreData
* Unit testing with Swift Combine
* UI testing with SwiftUI

## Requirements

* iOS 13
* Swift 5.1
* XCode 12

## Building

The app can be built using XCode. It requires a number of secrets that you will need to replace in order to be able to actually upload files. To do this, place a file named 'secrets' in the folder Travaartje, and put in your own values like this:

```
STRAVA_SECRET = mysecret
STRAVA_CLIENT_ID = myclientid
REDIRECT_URI = myuri
DEVELOPER_STRAVA_ID = mystravaid
APPCENTER_SECRET = myappcentersecret
```

During the build process they will be temporarily put into the Secrets.swift file.


## Testing ##

A full set of unit tests and UI tests is included.

## Who do I talk to? ##

* In case of questions you can contact berrie at travaartje dot net
