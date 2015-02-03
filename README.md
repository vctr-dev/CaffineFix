# CaffineFix
An app to get the locations of nearby coffee places

## Environment
- Xcode v6.1.1
- iOS 8.1
- Foursquare API (updated as on 30/1/2015)

## Screenshot
![Screenshot1](https://raw.githubusercontent.com/geekveek/CaffineFix/master/Screenshot%201.png "List of coffee shop example")
![Screenshot2](https://raw.githubusercontent.com/geekveek/CaffineFix/master/Screenshot%202.png "Coffee shop detail example")

## Features
- Shows list of coffee shops nearby
- Sort the list of coffee shops according to distance
- If state of coffee shop (opened, closed, open until... or closed until...) is available, display in red (for closed) or green (for open) the state of the coffee shop
- Shows price ratings (if available)
- Call coffee shop (if contact info is available) or view the coffee shop in Apple Maps app

## Assumptions
- User device has the hardware for geolocation.
- User device is able to make calls
- User device is able to make network calls to foursquare server
- Foursquare API response will maintain JSON structure for the version as on 30/1/2015

## Other Comments
- There is an Apple bug in table view cell - table view cell height resets to default when presenting view controller from table view. This only happens when table view cell height is set as automatic and vertical layout constraints are set for the table view cell. To workaround the bug, I call `tableView.reloadData()` when `viewWillAppear()` and `viewWillDisappear()` are called.
- Distances are rounded to the nearest 50 m for visual appeal.
