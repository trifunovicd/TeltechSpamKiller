# TeltechSpamKiller

TeltechSpamKiller is an application that processes incoming phone calls.

The app fetches a list of suspicious and scam numbers, then using Call Directory Extension, adds them as Identification or Blocking entries.
The user has the ability to see the list of all blocked numbers, and is able to add/edit its own entry, using manual input or selecting contact from the contact list.
If a number is added as an Identification entry, when the user receives an incoming call, the system will display an additional message "Suspicious Caller" to alert the user.
If a number is added as a Blocking entry, and that number is trying to reach the user, the user will not receive an incoming call.

App is currently loading phone numbers from a JSON file, and is not fetching data from the API.
For the app to work properly, user needs to enable Call extension from the phone settings and allow Contact access.
To enable Call extension go to Settings -> Phone -> Call Blocking & Identification.

Application is divided into three parts:
1. TeltechSpamKiller (Main project)
	- Holds all the UI and logic for the main Blocked list screen, Add/Edit Blocked screen and Contact picker
2. TeltechSpamKillerExtension (Call Directory Extension)
	- Holds handler that manages Identification and Blocking entries
3. TeltechSpamKillerData (Database)
	- Holds database and data manager, who is in charge of database operations

Architecture:
- Project is written using MVVM architecture
- Coordinator pattern is used for navigation
- ViewModelType pattern is used for defining input, output and dependencies structure
- UI is written programatically

Cocoapods is used for injecting libraries:
- RxSwift is used for reactive programming
- SnapKit is used for setting constraints
- R.swift is used for strings localization
- PhoneNumberKit is used for formatting phone numbers