cd backend
source ~/.rvm/scripts/rvm

rvm use 2.7.4
killall -9 ruby

gem install bundler
bundle install --jobs 4 --retry 3
export SECRET_KEY_BASE=rake secret
ruby -e 'p ENV["SECRET_KEY_BASE"]'
RAILS_ENV=production rake DISABLE_DATABASE_ENVIRONMENT_CHECK=1

bin/rails db:create RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1
bin/rails db:schema:load RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1

screen -dm bin/rails server -d -e production -p 4000

