# Copyright (c) 2011 Solano Labs All Rights Reserved

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
  t.rcov = true
  t.rcov_opts = ["-T", "--exclude", "gems/,lib/tddium/constant"]
end
task :default => :spec
