# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) starting from 1.x releases.

### Merged, but not yet released

> All recent changes are published

---

## Table of contents

#### 0.x Releases
- `0.15.x` Releases - [0.15.0](#0150)
- `0.14.x` Releases - [0.14.0](#0140) | [0.14.1](#0141) | [0.14.2](#0141) | [0.14.3](#0141) | [0.14.4](#0141) | [0.14.5](#0141)
- `0.13.x` Releases - [0.13.0](#0130) | [0.13.1](#0131)
- `0.12.x` Releases - [0.12.0](#0120)
- `0.11.x` Releases - [0.11.0](#0110)

---

## 0.15.0
Released on 2018-01-15.

#### Added
- Contact profile layout and properties.
- Call to update user information.
- Navigation to the contact profile from the messages.
- Exposing mediQuo role option set required to configure filtered view.
- Added limitation to query results using realm lazy load.
- Implemented a sample example for filtered view.
- Expose inbox content size listener.

#### Improved
- Checking the message status event to emit contacts request every time update event is received.

#### Fixed
- Correctly managing disabled contacts on holiday and with last timestamp message to zero.
- Pinning public keys instead of full byte to byte comparison.

---

## 0.14.5
Released on 2018-01-04.

#### Changed
- Changed socket queue from concurrent to serial.

---

## 0.14.4
Released on 2018-01-03.

#### Changed
- Updated the pods of the framework.

---

## 0.14.3
Released on 2017-12-29.

#### Changed
- The messenger view controller is now instantiated using the storyboard.

---

## 0.14.2
Released on 2017-12-29.

#### Fixed
- Concurrency problem with socket.io events.

---

## 0.14.1
Released on 2017-12-22.

#### Fixed
- Absence of divider behaviour should allow users to start conversations with any professional.

---

## 0.14.0
Released on 2017-12-20.

#### Added
- Link detector types for links in users conversations.
- Tap file message event to download content.

#### Updated
- MessageKit pod version 0.12.0. 

---

## 0.13.1
Released on 2017-12-19.

#### Fixed
- Connection problem while authentication and shutdown in the same session. Connection dispatchers were not attaching correctly due to incorrect call order that could be by-passed by calling again `initialize` method. 

---

## 0.13.0
Released on 2017-12-18.

#### Added
- `shutdown` method dettaches user connections and wipes out stored user information.

#### Fixed
- Professional list order to match Android implementation. 

---

## 0.12.0
Released on 2017-12-11.

#### Added
- `preferredStatusBarStyle` exposes default `UIStatusBarStyle` used in framework controllers.
- `MediQuoDividerType` protocol enables interaction with inbox contact list items by allowing to include a custom view and react to user item selections.
- Generic `MediQuoDivider` builder to configure an inbox list divider view group.

#### Improved
- All internal database notification operations work now in a subscribed run loop thread that allows to improve performance.

#### Fixed
- Reversed inbox contact list order due to a problem with sort order of contacts with previous interactions.
- Localized date patterns for date/time messages.

---

## 0.11.0
Released on 2017-12-03.

#### Added
- Expose inbox contact list professional schedule.
- Full database encryption (per device installation keychain key) for release distributions.
- Sorted inbox contact list by marketing criterias.
- Expose bubble and text color to style conversation messages.
- Localized day/month message header for conversation messages.

#### Fixed
- Send correct device model name in installation.
