# Upload Users
*Scope:* Users

```
{
    t.string "email"
    t.string "encrypted_password"
    t.string "name"
    t.integer "bank_value"
    t.integer "humanity_user_id"
    t.boolean "ten_hour_shift"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "position"
    t.string "team"
    t.string "start_time"
    t.string "end_time"
    t.integer "work_days"
    t.boolean "admin"
    t.boolean "on_pip"
    t.integer "no_call_show"
    t.integer "make_up_days"
    t.datetime "start_date"
    t.boolean "is_deleted"
    t.string "color"
    t.string "phone_number"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
}
```
## upload_users - _depricated_
_affected roles: admin_

The Upload Users function is a manual way to seed users into PandaPTO - accepts a CSV of User data:

| Field Name | Value Type | Description |
| ----------- | ----------- | -----------|
|`name`|string| The name of the agent|
|`email`|string| The @instructure.com email address of the user|
|`team`|string| The name of the team that the agent belongs to|
|`start_time`| time| The Shift Hour/Minute Start time of the user formatted `hh:mmZ`|
|`end_time`| time | The Shift Hour/Minute End time of the user formatted `hh:mmZ`|
|`start_date`| date | The hire date of the agent formatted `YYYY-MM-DD` Note: if omitted or blank will be set to `1970-01-01`|
|`work_days`| int list | The days of the week that the agent works where Sunday is 0|
|`position`| enum | The position of the user. Allowed values: `sup`,`l3`,`l2`,`l1`|
|`admin`| boolean | If the user has admin permissions|
|`is_deleted`| boolean | If the user is in a deleted state|

#### Example
[users.csv](https://docs.google.com/spreadsheets/d/1-JXul3UWsswN8qybftm0e_hV2_tlzQGu7rMuDBX7PyE/edit?usp=sharing)

## humanity_import

New users are created when the humanity_import is triggered by the `sync_humanity_users` rake task.

The `new_hire_check_pip` checks if users are >90 days old and falsifies their on_pip status.

[Humanity API](https://platform.humanity.com)

## Password Reset
_affects: admin, sup_

Generates a new "Password Reset" email for the user.

## 8/10 Hour Shift
_affects: admin, sup_

Switches the user's Shift between 8 and 10 hours. This is used to determine the cost of the user's PTO requests.

## Toggle Admin
_affects: admin_

Toggles the user's admin privleges.

## Toggle Pip
_affects: admin_

Toggles whether the users is currently on a PIP. Being on a pip prevents users from creating new PTO requests for themselves.

## Delete User
_affects: admin_

Soft deletes the user. Deleted users will not display on the admin index page. This will hard delete any future PTO requests that belong to the user.