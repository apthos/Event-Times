Original App Design Project
===

# Event Times

## Table of Contents
1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)
5. [Journal](#Journal)

## Overview
### Description
Event Times is an app centered around scheduling events. Users can create events that other users join. The app provides a way to look over an event on the go and plan their experience.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Productivity, Travel
- **Mobile:** The app allows users to look at their schedule on the go while they're at the event. It can, also, display the location for activities that can be shown on a map.
- **Story:** Users can better manage trips and events, and personalize their experience given the opportunity.
- **Market:** Users include event goers and travelers. Being able to organize your schedule on the day of an event or trip makes enjoying your time there much easier.
- **Habit:** For avid event goers and travelers, they might use this app once a month. Users would be personalizing their experience mainly but some must create the events/main itinerary for others to attend.
- **Scope:** A functioning and useful itinerary app will be manageable to complete. The main challenge will be creating events and letting people add the itinerary of the event to their own calendar.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Setting up a database to store events, profiles, etc.
* Users can login to/logout of/sign up for an account
* Users can take a photo with their camera and display it as their profile picture
* Users can create and post an event with information pertaining to the event and a list of activities
* Users can view the details of an event and activities
* Users can join/leave activities of an event
* Users can view the list of activities they have signed up for in order of occurence
* Users can edit/delete events they have created

**Optional Nice-to-have Stories**

* Users may view directions to an activity/event with Apple Maps

### 2. Screen Archetypes

* Events
   * Users can view a list of recommended and public events
* Event Details
    * Users can view the event's information (location, dates, description) and a list of its activities
* Event Creation
    * Users can input information regarding the event being created
* Schedule
   * Users can view a list of activities
* Login page
   * Users can login to an account
* Sign Up page
   * Users can create an account
* Profile
    * Users can take a photo with their camera and display it as their profile picture
    * Users can view a list of their created events and choose to edit or delete them

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Events
* Schedule
* Profile

**Flow Navigation** (Screen to Screen)

* Events
   * Event Details
   * Event Creation
* Event Details
    * Activity Details
* Event Creation
    * Activity Creation
* Schedule
   * Activity Details
* Profile
   * Event Details
   * Event Creation

#### 4. Recommendation Algorithm
The app recommends events for the user to attend. The algorithm obtains a set of the tags of the events a user is currently attending. Then, the tags of events a user is not attending are compared to the aforementioned set of tags. Events with the highest amount of tag overlap are chosen as recommendations for the user.

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
| location | PFGeopoint | location containing latitude and longitude |
| street | String | street name for the address |
| city | String | city name for the address |
| state | String | state name for the address |
| postalCode | String | postal code for the address |
| country | String | country for the address |

### Networking
* Events
   * (Read/GET) Query all events
   * (Read/GET) Query events the user is attending
* Event Details
    * (Read/GET) Query for event details including activities
    * (Update/PUT) Update whether the user is attending a select activity
* Event Creation
    * (Create/POST) Create an event object
    * (Create/POST) Create an activity object for each activity
* Calendar
   * (Read/GET) Query activities user is attending
   * (Update/PUT) Update whether the user is attending a select activity
* Profile
    * (Read/GET) Query for events that the user is attending (including those created by them)
    * (Update/PUT) Update the user profile image
    * (Delete/DELETE) Delete an existing event
    
## Journal
#### July 14
- Decided to use Apple MapKit over the Google Maps SDK due to simplicity of implementation. The MapKit would not need an external SDK installed. Additionally, location auto complete is possible with MapKit alone rather than needing the Google Places SDK.
- Decided on using a custom PFObject to store the placemark of the locations the events will be held at. MKPlacemarks nor MKMapItems may be stored in Parse, so a custom PFObject containing the relevant information must be made. Upon requesting the location to be displayed on a map, an MKPlacemark will be made using the information from the custom PFObject.
#### July 16
- Decided to implement event creation with a dynamic table view instead of a static table view. When I was using a static table, the date picker cell would not appear. After looking into the issue, I discovered that adding more cells to a static table would not work no matter which method I tried. 
#### July 17 
- Implemented the location picker feature resulting in it returning an MKMapItem. I chose to use an MKMapItem as it has a method that opens the Apple Maps app and displays the location for the user.
#### July 22
- Decided to use an enum to define the order of the event/activity creation tables.
- Implemented a new data object that stores data and an enum describing what kind of data it is, such as the location of an event/activity. By implementing this data object, I am able to create an array of one type and use that array to decided what to display for a given row. The choice of what is to be displayed and what kind of cell should be used will be decided by the enum that the data object has. The enums are defined by the enum that defines the order of the event/activity creation tables.
- Decided to change the storing of a tags from an NSArray to an NSSet. This is due to not needing the indexes and being able to add/delete items quicker.
#### July 23
- Went back on my decision to change the storing of tags. Upon further inspection, an NSSet is not allowed to be stored in Parse. However, using an NSSet in the tags view controller is beneficial, so it is still in use while the user is selecting and unselecting tags. When the tags property of the event is set, the set is turned into an array for storage purposes.
#### July 24
- Decided to not save the activity upon activity creation. The activity will only be saved to the database when the event is saved. This will prevent creating activities with no attached event, in the case the user decides not to save the event they were creating.
#### July 31
- Decided to display the user's created events on the profile view controller. Originally, I planned on displaying a new view controller, but it is unnecessary to split the profile and the user's created events into two different view controllers. 
- Decided to implement a long press gesture recognizer for managing a users' events. By holding down on an event in the "My Events" table, an action sheet appears with options to either edit or delete the event. 
#### August 4
- Decided to add visual polish by incorporating the Material Design library by Google. Material Design includes many components that can enhance the user experience of my app. The implementation seems to be mainly programmatic, which will require some refactoring in my code. 
