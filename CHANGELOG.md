# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) starting from 1.x releases.

### Merged, but not yet released

> All recent changes are published

---

## Table of contents

#### 0.x Releases
- `0.12.x` Releases - 0.12.0
- `0.11.x` Releases - 0.11.0

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
