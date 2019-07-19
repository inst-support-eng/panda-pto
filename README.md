## panda-pto

### Local Install Instructions

1. clone repository `https://github.com/inst-support-eng/panda-pto.git`
1. navigate to repository `cd panda-pto`
1. install postres (skip if you already have this) `brew install postgresql`
    - note: installing postgres via brew can create some issues out-of-the box. Reccomend following instructions here to get up and running: https://bit.ly/2IvXXDB
1. install dependancies `bundle install`
1. `bundle exec rake db:create`
1. `bundle exec rake db:migrate`

to run locally `rails s`

---

#### Scheduled Tasks
All scheduled and recurring actions are currently written as rake tasks, and are executed using the [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) plugin. 
- For nightly coverage e-mails, add `rake coverage_mailer` as a daily job in scheduler 
- To enable quarterly point seeding, add `rake quarterly_seed` as a daily job in scheduler
- To have new agents automactailly removed from a pip after 90 days, add  `rake new_hire_check_pip` as a daily job in scheduler
- To enable L1 agent syncs from Humanity add `rake sync_humanity_users` to scheduler. 
    - Note: only agents with the 'schedules' value of 'L1 Phones', other positions will need to manually uploaded via CSV


#### Google API set up
This application utilizes the Google Sheets API for automated data syncs. A Google API project is needed to access these APIs. Once you have this, you can follow [this guide](https://cloud.google.com/docs/authentication/production#obtaining_and_providing_service_account_credentials_manually) to set up Service-to-Service authentication on the Google side. 

Once you've aquired a credentials.json file from above, you'll need to configure it in the enviroment.

##### For a local enviorment
1. Add the .json file to to the `/config` directory
1. In your .env file, create an enviormental variable for `GOOGLE_APPLICATION_CREDENTIALS` pointing to the .json file from step one. ex) `GOOGLE_APPLICATION_CREDENTIALS=config/google_credentials.json`

##### For Heroku
1. run `heroku config:set GOOGLE_APPLICATION_CREDENTIALS="$(< /local/path/to/google_credentials.json)"`