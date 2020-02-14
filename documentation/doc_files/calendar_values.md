# Calendar Values

*scope:* calendars

```
}
    t.date "date"
    t.float "base_value"
    t.integer "signed_up_total"
    t.text "signed_up_agents"
    t.float "current_price" 
    t.datetime "created_at"
    t.datetime "updated_at"
{
```

## upload_values
_affected roles: admin_

The Upload Values function allows an user with Admin privleges to set the initial cost of a day in a Calendar Year. The Function opens as a modal which allows a user to upload a CSV file. These values will determine the cost for the first person who signs up for a day off on that date. Costs of subsequent requests will be calculated based on the number of requests for that date already set.

| Field Name | Value Type | Description | 
| -------- | -------- | -------- | 
| `date` | date | The day you would like to set the intial value for; formatted `YYYY-MM-DD` |
| `base_value`| int | This non-negative integer is the inital value you would like to set for the first PTO request created on that day |

### Example
[2020 base_values](https://docs.google.com/spreadsheets/d/1zXoLjf9q28gHDhNp_M0yqnusB13j0-QODyYtI57nevg/edit?usp=sharing)