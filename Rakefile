require 'rubygems'
begin
  require 'bundler'
  require 'bundler/setup'
  require 'date' 
  begin
    Bundler.setup
    require 'xctasks/test_task'
  rescue Bundler::GemNotFound => gemException
    raise LoadError, gemException.to_s
  end
rescue LoadError => exception
  unless ARGV.include?('init')
    puts "Rescued exception: #{exception}"
    puts "WARNING: Failed to load dependencies: Is the project initialized? Run `rake init`"
  end
end

# Enable realtime output under Jenkins
if ENV['JENKINS_HOME']
  STDOUT.sync = true
  STDERR.sync = true
end

desc "Initialize the project for development and testing"
task :init do
  puts green("Update submodules...")
  run("git submodule update --init --recursive")
  puts green("Checking for Homebrew...")
  run("which brew > /dev/null && brew update; true")
  run("which brew > /dev/null || ruby -e \"$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)\"")
  puts green("Bundling Homebrew packages...")
  packages = %w{rbenv ruby-build rbenv-gem-rehash rbenv-binstubs xctool thrift}
  packages.each { |package| run("brew install #{package} || brew upgrade #{package}") }
  puts green("Checking rbenv version...")
  run("rbenv version-name || rbenv install")
  puts green("Checking for Bundler...")
  run("rbenv whence bundle | grep `cat .ruby-version` || rbenv exec gem install bundler")
  puts green("Bundling Ruby Gems...")
  run("rbenv exec bundle install --binstubs .bundle/bin --quiet")
  puts green("Ensuring Layer Specs repository")
  run("[ -d ~/.cocoapods/repos/layer ] || rbenv exec bundle exec pod repo add layer git@github.com:layerhq/cocoapods-specs.git")
  puts green("Installing CocoaPods...")
  run("rbenv exec bundle exec pod install --verbose")
  puts green("Checking rbenv configuration...")
  system <<-SH
  if [ -f ~/.zshrc ]; then
    grep -q 'rbenv init' ~/.zshrc || echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.zshrc
  else
    grep -q 'rbenv init' ~/.bash_profile || echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.bash_profile
  fi
  SH
  puts "\n" + yellow("If first initialization, load rbenv by executing:")
  puts grey("$ `eval \"$(rbenv init - --no-rehash)\"`")
end

if defined?(XCTasks)
  XCTasks::TestTask.new(test: :sim) do |t|
    t.workspace = 'LayerUIKit.xcworkspace'
    t.schemes_dir = 'Tests/Schemes'
    t.runner = :xcpretty
    t.output_log = 'xcodebuild.log'
    t.subtask(app: 'Unit Tests') do |s|
      s.destination do |d|
        d.platform = :iossimulator
        d.name = 'LayerUIKit-Test-Device'
        d.os = :latest
      end
    end    
  end
end

desc "Initialize the project for build and test with Travis-CI"
task :travis do
  puts green("Ensuring Layer Specs repository")
  run("[ -d ~/.cocoapods/repos/layer ] || rbenv exec bundle exec pod repo add layer git@github.com:layerhq/cocoapods-specs.git")
end

desc "Creates a Testing Simulator configured for LayerUIKit Testing"
task :sim do
  # Check if LayerUIKit Test Device Exists
  device = `xcrun simctl list | grep LayerUIKit-Test-Device`
  if $?.exitstatus.zero?
    puts ("Found Layer Test Device #{device}")
    device.each_line do |line|
      if device_id = line.match(/\(([^\)]+)/)[1]
        puts green ("Deleting device with ID #{device_id}")
        run ("xcrun simctl delete #{device_id}")
      end
    end
  end
  puts green ("Creating iOS simulator for LayerUIKit Testing")
  run("xcrun simctl create LayerUIKit-Test-Device com.apple.CoreSimulator.SimDeviceType.iPhone-6 com.apple.CoreSimulator.SimRuntime.iOS-8-1")
end

desc "Prints the current version of LayerUIKit"
task :version do  
  puts layerUIkit_version
end

namespace :version do
  desc "Sets the version by updating LayerUIKit.podspec and Code/LayerUIKit.m"
  task :set => :fetch_origin do
    version = ENV['VERSION']
    if version.nil? || version == ''
      fail "You must specify a VERSION"
    end
    
    existing_tag = `git tag -l v#{version}`.chomp
    if existing_tag != ''
      fail "A tag already exists for version v#{version}: please specify a unique release version."
    end
    
    podspec_path = File.join(File.dirname(__FILE__), 'LayerUIKit.podspec')
    podspec_content = File.read(podspec_path)
    unless podspec_content.gsub!(/(\.version\s+=\s+)['"](.+)['"]$/, "\\1'#{version}'")
      raise "Unable to update version of Podspec: version attribute not matched."
    end
    File.open(podspec_path, 'w') { |f| f << podspec_content }
    
    layerUIkit_m_path = File.join(File.dirname(__FILE__), 'Code', 'LayerUIKit.m')
    layerUIkit_m_content = File.read(layerUIkit_m_path)    
    unless layerUIkit_m_content.gsub!(/(LYRUIKitVersionString\s+=\s+@\")(.+)(\";)/, "\\1#{version}\\3")
      raise "Unable to update LYRUIKitVersionString in #{layerUIkit_m_path}: version string not matched."
    end
    File.open(layerUIkit_m_path, 'w') { |f| f << layerUIkit_m_content }
    
    run "git add LayerUIKit.podspec Code/LayerUIKit.m"
    
    require 'highline/import'    
    system("git diff --cached") if agree("Review package diff? (y/n) ")
    system("bundle exec pod update") if agree("Run `pod update`? (y/n) ")
    system("git commit -m 'Updating version to #{version}' LayerUIKit.podspec Code/LayerUIKit.m Podfile.lock") if agree("Commit package artifacts? (y/n) ")
  end
end

task :fetch_origin do
  run "git fetch origin --tags"
end

# Safe to run when Bundler is not available
def with_clean_env(&block)
  if defined?(Bundler)
    Bundler.with_clean_env(&block)
  else
    yield
  end
end

def run(command, options = {})
  puts "Executing `#{command}`" unless options[:quiet]
  unless with_clean_env { system(command) }
    fail("Command exited with non-zero exit status (#{$?}): `#{command}`")
  end
end

def layerUIkit_version
  path = File.join(File.dirname(__FILE__), 'LayerUIKit.podspec')
  version = File.read(path).match(/\.version\s+=\s+['"](.+)['"]$/)[1]
end

def green(string)
 "\033[1;32m* #{string}\033[0m"
end

def yellow(string)
 "\033[1;33m>> #{string}\033[0m"
end

def grey(string)
 "\033[0;37m#{string}\033[0m"
end
