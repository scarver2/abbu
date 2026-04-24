# spec/spec_helper.rb
# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 100
end

require 'abbu'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
