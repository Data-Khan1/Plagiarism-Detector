#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle install
rails db:create
rails db:migrate
bundle exec rails assets:clean