# Rakefile
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

# Load our custom abbu tasks
Dir.glob('tasks/**/*.rake').each { |r| import r }

task default: %i[rubocop spec]
