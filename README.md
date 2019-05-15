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

#### Scheduled Tasks
All scheduled and recurring actions are currently written as rake tasks, and are executed using the [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) plugin. 
- For nightly coverage e-mails, add `rake coverage_mailer` as a daily job in scheduler 
- To enable quarterly point seeding, add `rake quarterly_seed` as a daily job in scheduler
- For pip checking for new hires, add  `rake new_hire_check_pip` as a daily job 

