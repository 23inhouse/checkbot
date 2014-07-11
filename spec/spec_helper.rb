require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end if !ENV['SIMPLECOV'].nil?

require 'checkbot'

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
