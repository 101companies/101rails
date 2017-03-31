#!/usr/bin/env puma

directory '/home/ubuntu/101rails/current'
rackup "/home/ubuntu/101rails/current/config.ru"
environment 'production'

pidfile "/home/ubuntu/101rails/shared/tmp/pids/puma.pid"
state_path "/home/ubuntu/101rails/shared/tmp/pids/puma.state"
stdout_redirect '/home/ubuntu/101rails/shared/log/puma_access.log', '/home/ubuntu/101rails/shared/log/puma_error.log', true

threads 0,4

bind 'tcp://localhost:3000'

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "/home/ubuntu/101rails/current/Gemfile"
end
