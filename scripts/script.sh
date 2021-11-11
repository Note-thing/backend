cd backend
source ~/.rvm/scripts/rvm

rvm use 2.7.4

# kill -INT $(cat tmp/pids/server.pid)

gem install bundler
bundle install --jobs 4 --retry 3
export SECRET_KEY_BASE=rake secret
ruby -e 'p ENV["SECRET_KEY_BASE"]'
RAILS_ENV=production rake DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# rails credentials:edit RAILS_ENV=production
bin/rails db:create RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1
bin/rails db:schema:load RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# rm -f tmp/pids/server.pid
# killall -9 rails
killall -9 ruby
bin/rails server -e production -p 4000 -d

exit 0 
