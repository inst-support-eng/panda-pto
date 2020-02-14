# PTO Requests

*scope:* pto requests

```
{
    t.string "reason"
    t.date "request_date"
    t.integer "cost"
    t.integer "signed_up_total"
    t.integer "user_id"
    t.integer "humanity_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "admin_note"
    t.boolean "excused"
    t.string "position"
    t.boolean "is_deleted"
}
```

## import requests
_affects: admins_

Importing PTO requests allows an Admin to upload a CSV to create new PTO requests for users.

| Field Name | Value Type | Description |
| ----------- | ----------- | -----------|
| `email` | string | The email of the user for which the PTO request will be created |
| `date` | date | The date of the new PTO request |
| `price` | int | The cost to the user for the PTO request |
| `reason` | string | The reasone/explaination for the creation of the pto request |

## Export PTO
_affects: admins_

Export PTO generates a CSV of all PTO requests, including soft deleted requests.

| Field Name | Value Type | Description |
| ----------- | ----------- | -----------|
| `name` | string | The name of the use on the request|
| `email` | string | The email of the owning user of the PTO request |
| `date` | date | The date of the PTO request |
| `price` | int | The cost that the user paid for the PTO request |
| `reason` | string | The reasone/explaination for the creation of the pto request |
| `signed_up_total` | int | The number of PTO requests for the same day at the time of PTO request creation | 
| `excused` | boolean | Whether the PTO request has been excused by and admin or sup | 
| `same_day`| boolean | Whether the PTO request was created for the same day it was requested |
| `created_at` | date | The date and time of the PTO request creation formatted in `YYYY-MM-DD HH:MM:SS UTC`|
| `is_deleted` | boolean | Whether the PTO request is soft deleted |

#### example
[PTO Export/Import](https://docs.google.com/spreadsheets/d/1jNfVuGBkVOuJQK8-dLThQ_2LVuRT-3Jb0D85_sVlJGU/edit?usp=sharing)

## Sync
The `check_long_requests` rake task runs daily. It checks wether a user has created a set of 4 consecutive PTO requests in a recent period. It notifies Fleet Command of any such requests.

## User PTO Requests
_affects: admin, sup_

Export PTO generates a CSV of the viewed User's PTO requests, including soft deleted requests. Same formatting as _Export PTO._

## Add Request
_affects: admin, sup_

Generate a new PTO request for the viewed user.

## Add No Show
_affects: admin, sup_

Generate a new, zero point PTO request for the user with the reason "No Call / No Show."

## Add Make Up/Sick Day
_affects: admin, sup_

Generate a new, zero point PTO request for the user with the reason "make up / sick day"

## Delete request
_affects; admin, sup_

Soft Deletes the connected PTO request.

## Excuse Request
_affects; admin, sup_

Sets the Excused status of the PTO request to TRUE, sets the cost of the PTO request to 0 and refunds previously used points. 



