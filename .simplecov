require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
]

SimpleCov.start('rails')
