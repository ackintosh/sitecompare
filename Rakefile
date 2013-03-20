require 'rspec/core/rake_task'

$:.push File.expand_path("../lib", __FILE__)

task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

