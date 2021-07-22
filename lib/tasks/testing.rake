require "rake/testtask"

Rake::TestTask.new("test:integration:engine") do |t|
  t.libs << "test"
  t.test_files = Dir["test/integration/engine/**/*_test.rb"]
end

Rake::TestTask.new("test:integration:flows") do |t|
  t.libs << "test"
  t.test_files = Dir["test/integration/flows/**/*_test.rb"]
end

Rake::TestTask.new("test:unit:calculators") do |t|
  t.libs << "test"
  t.test_files = Dir["test/unit/calculators/**/*_test.rb"]
end
