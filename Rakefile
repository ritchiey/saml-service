require 'rubocop/rake_task'
require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks
RuboCop::RakeTask.new

task default: [:spec, :rubocop]
