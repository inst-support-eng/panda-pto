# Calendar
The Calendar provides the main function for PandaPTO users - they can view their upcoming requests, their remaining bank balance for the current available quarters, and they can create new requests for Time Off.

## Quarterly Balance
The Calendar should show the remaining balance for each quarter based on the requests made in prior and present quarters. A users's inital bank balance of 180 is subdivided by quarter to display the appropriate remaining balance.

## Upcoming Requests
A list of a user's upcoming requests should be displayed. This should show the date of the request, at least a partial preview of the reason, and an option to Delete the request. When upcoming requests are deleted here they should be soft deleted.

## Calendar Body
The Calendar provides options to navigate to different months and years. The calendar displays days of the month. The Cost of the day is displayed in the calendar day. The cost is pulled from the Calendar Tables of each respective position. Past days are indicated in a dark gray. It is not possible for a user to enter a new request on the current day. Current day is indicated in a deep blue. It is not possible to for a user to create a same-day request. Users on a PIP are not able to create new requests.

To create a request, a user should click on an upcoming day. If the user has sufficient quarterly bank value to complete the request, they will be able to enter a reason for the request and  an option to submit the request. Each request requires a reason. 

Days that have already been requested are indicated in light blue. A user cannot create multiple requests for the same day.