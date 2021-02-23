require 'fileutils'

path_datapoints = "workflows"

# to use on windows, follow the directions here:
# http://nrel.github.io/OpenStudio-user-documentation/reference/command_line_interface/#loading-custom-gems-with-bundler-in-the-cli
# - make a custom gems folder and link to it
# - if updating openstudio-standards, use bundle exec rake install on openstudio-standards, then copy the installed gem to this directory

# test directories
test_directories = ['json_test_chicago',
                    'json_test_chicago_stratified_hpwh']

# loop through resource files
jobs = []
results_directories = Dir.glob("#{path_datapoints}/*")
results_directories.each do |directory|
  next unless test_directories.include? directory.gsub("#{path_datapoints}/",'')
  #next if not directory.include?('json_')
  test_dir = "#{directory}/floorplan.osw"
  #string = "openstudio --verbose --gem_path C:/Ruby22-x64/lib/ruby/gems/2.2.0/gems/openstudio-standards-0.2.10 run --measures_only --workflow '#{test_dir}'"
  #string = "openstudio --verbose --bundle '#{Dir.pwd}/Gemfile' --bundle_path 'C:/Users/mdahlhau/Documents/gems' run --measures_only --workflow '#{test_dir}'"
  string = "openstudio --verbose --bundle '#{Dir.pwd}/Gemfile' --bundle_path 'C:/Users/mdahlhau/Documents/gems' run --workflow '#{test_dir}'"
  if not File.file?(test_dir)
    puts "data_point.osw not found for #{directory}"
    next
  end

  # system(string)
  jobs << string
  puts "running #{directory}"
end

# run the jobs
# if gem parallel isn't installed then comment out this could and use system(string) to run one job at a time
require 'parallel'
num_parallel = 11
Parallel.each(jobs, in_threads: num_parallel) do |job|
  puts job
  # blank out bundler and gem path modifications, will be re-setup by new call
  new_env = {}
  new_env['BUNDLER_ORIG_MANPATH'] = nil
  new_env['BUNDLER_ORIG_PATH'] = nil
  new_env['BUNDLER_VERSION'] = nil
  new_env['BUNDLE_BIN_PATH'] = nil
  new_env['RUBYLIB'] = nil
  new_env['RUBYOPT'] = nil

  # DLM: preserve GEM_HOME and GEM_PATH set by current bundle because we are not supporting bundle
  # requires to ruby gems will work, will fail if we require a native gem
  new_env['GEM_PATH'] = nil
  new_env['GEM_HOME'] = nil

  # DLM: for now, ignore current bundle in case it has binary dependencies in it
  #bundle_gemfile = ENV['BUNDLE_GEMFILE']
  #bundle_path = ENV['BUNDLE_PATH']
  #if bundle_gemfile.nil? || bundle_path.nil?
    new_env['BUNDLE_GEMFILE'] = nil
    new_env['BUNDLE_PATH'] = nil
    new_env['BUNDLE_WITHOUT'] = nil
  #else
  #  new_env['BUNDLE_GEMFILE'] = bundle_gemfile
  #  new_env['BUNDLE_PATH'] = bundle_path
  #end

  system(new_env, job)
end