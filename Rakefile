require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

FileList['dev_tasks/**/*.rake', 'tasks/**/*.rake'].each { |file| load(file) }

task :default => :spec
