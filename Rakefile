require 'rspec/core/rake_task'

$:.unshift File.join(File.dirname(__FILE__), '..')

task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

