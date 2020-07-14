Original App Design Project
===

# Event Times

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Event Times is an app centered around scheduling events. Users can create events that other users join and obtain the itinerary for it. The app provides a way to look over an itinerary on the go and customize your own itinerary.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Productivity, Travel
- **Mobile:** The app allows users to look at their itinerary on the go while they're at the event. It can, also, display the location for activities that can be shown on a map.
- **Story:** Users can better manage trips and events, and personalize their experience given the opportunity.
- **Market:** Users include event goers and travelers. Being able to organize your schedule on the day of an event or trip makes enjoying your time there much easier.
- **Habit:** For avid event goers and travelers, they might use this app once a month. Users would be personalizing their experience mainly but some must create the events/main itinerary for others to attend.
- **Scope:** A functioning and useful itinerary app will be manageable to complete. The main challenge will be creating events and letting people add the itinerary of the event to their own calendar.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Setting up a database to store events, profiles, etc.
* Users can login to/create an account
* Users can take a photo with their camera and display it as their profile picture or put it as the image for the event
* Users can create an event and the itinerary for it
* Users can join events and obtain the itinerary
* Users can view a calendar in the app
* Users can choose specific activities on the itineraries to attend
* Users can use gestures to edit their itinerary (holding down on an activity will bring up an option to add/remove)
* Animations appear when going through views
* Use an external library for UI

**Optional Nice-to-have Stories**

* Users can collaborate on the itinerary
* Users may view directions to an activity on the itinerary inside the app or with Apple/Google Maps
* Users can export their calendar to other calendar apps such as Google Calendar

### 2. Screen Archetypes

* Events
   * Users can view events and obtain the itinerary
   * Users can create an event and the itinerary for it
* Event Details
    * Users can choose specific activities on the itineraries to attend
* Event Creation
    * Users can create an event and the itinerary for it
* Calendar
   * Users can view a calendar in the app
   * Users can use gestures to edit their itinerary (holding down on an activity will bring up an option to add/remove)
* Login page
   * Users can login to/create an account
* Create account page
   * Users can login to/create an account
* Profile
    * Users can take a photo with their camera and display it as their profile picture or put it as the image for the event

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Events
* Calendar
* Profile

**Flow Navigation** (Screen to Screen)

* Events
   * Event Details
   * Event Creation
* Event Details
    * Activity Details
* Event Creation
    * Activity Creation
* Calendar
   * Activity Details
   * Activity Creation
* Profile
    * My Events
    * Settings

## Wireframes
https://www.figma.com/file/n2yZHyJQqym1NHQA8zysuo/Independent?node-id=0%3A1

## Schema 

### Models

#### User Data Model
| Property | Type | Description |
| -------- | ---- | ----------- |
| objectId | String | unique id for the event |
| createdAt | Date | date when account was created |
| email | String | user's email |
| username | String | unique username given by the user |
| password | String | password for login |
| profileImage | PFFileObject | selected profile image |
| activities | Relation | list of activities the user is attending |
| events | Relation | list of events the user is attending |
| createdEvents | Relation | list of events the user has created |

#### Event Data Model
| Property | Type | Description |
| -------- | ---- | ----------- |
| objectId | String | unique id for the event |
| createdAt | Date | date when event was created |
| author | Pointer to User | event creator |
| name | String | event name |
| startDate | Date | start date for the event|
| endDate | Date | end date for the event |
| info | String | description of event |
| location | Placemark | location of event |
| tags | Array | list of tags that categorize the event |
| participants | Relation | list of users attending the event |

#### Activity Data Model
| Property | Type | Description |
| -------- | ---- | ----------- |
| objectId | String | unique id for the activity |
| createdAt | Date | date when activity was created |
| author | Pointer to User | activity creator |
| name | String | activity name |
| startDate | Date | start date and time for the activity|
| endDate | Date | end date and time for the activity |
| info | String | description of activity |
| location | Placemark | location of activity |
| event | Pointer to Event | event the activity is taking place during |
| participants | Relation | list of users attending the activity |

#### Placemark Data Model
| Property | Type | Description |
| -------- | ---- | ----------- |
| name | String | placemark name |
| location | PFGeoPoint | location containing latitude and longitude |
| street | String | street name for the address |
| city | String | city name for the address |
| state | String | state name for the address |
| postalCode | String | postal code for the address |
| country | String | country for the address |

### Networking
* Events
   * (Read/GET) Query all events
   * (Read/GET) Query events that are recommended to the user
* Event Details
    * (Read/GET) Query for event details including activities
    * (Update/PUT) Update whether the user is attending a select activity
* Event Creation
    * (Create/POST) Create an event object
    * (Delete/DELETE) Delete a created activity
* Activity Creation
    * (Create/POST) Create an activity object
* Activity Edit
    * (Update/PUT) Update an existing activity object
* Calendar
   * (Read/GET) Query activities user is attending
   * (Update/PUT) Update whether the user is attending a select activity
   * (Delete/DELETE) Delete a personal activity
* Profile
    * (Read/GET) Query logged in user object
    * (Update/PUT) Update the user profile image
* My Events
    * (Read/GET) Query for events that the user is attending (including those created by them)

- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]