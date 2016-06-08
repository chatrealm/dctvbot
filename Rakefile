# file: Rakefile

require 'rake/testtask'

Rake::TestTask.new do |task|
  task.libs << ['test']
  task.test_files = FileList['test/**/*_test.rb']
  task.warning = false
end
