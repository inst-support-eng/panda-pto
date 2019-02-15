## panda-pto

### Local Install Instructions

1. clone repository `https://github.com/BlinkVonDoom/panda-pto.git`
1. navigate to repository `cd panda-pto`
1. install postres (skip if you already have this) `brew install postgresql`
1. install dependancies `bundle install`
1. `bundle exec rake db:create`
1. `bundle exec rake db:migrate`

to run locally `rails s`
