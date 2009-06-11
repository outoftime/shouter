require 'spec/rake/spectask'

desc 'Run all specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/examples/**/*_spec.rb']
  t.spec_opts << '--color'
end
