cd backend
source ~/.rvm/scripts/rvm

rvm use 2.7.4

gem install bundler
bundle install --jobs 4 --retry 3

bin/rails db:migrate RAILS_ENV=production
sudo systemctl start notething

