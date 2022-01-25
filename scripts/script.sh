cd backend
source ~/.rvm/scripts/rvm

rvm use 2.7.4

gem install bundler
bundle install --jobs 4 --retry 3

sudo systemctl start notething

