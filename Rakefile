desc 'Open a pry or irb session preloaded with Refinery'
task :console do
  command = system("which pry > /dev/null 2>&1") ? 'pry' : 'irb'
  exec "#{ command } -I./lib -r./lib/refinery.rb"
end
