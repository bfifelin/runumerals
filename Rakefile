require File.expand_path(File.dirname(__FILE__) + '/lib/version.rb')

task :build => :gendoc do
  system "gem build runumerals.gemspec"
end


task :gendoc do
  system "yardoc"
end


task :release => :build do
  system "gem push axlsx-#{RuNumerals::VERSION}.gem"
end

task :default => :build