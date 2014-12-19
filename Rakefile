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
  run("rbenv exec bundle exec pod install")
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
  XCTasks::TestTask.new(test: [:ensure_ports_are_open, :remove_project_schemes]) do |t|
    t.workspace = 'LayerKit.xcworkspace'
    t.schemes_dir = 'Tests/Schemes'
    t.runner = "xcpretty " + (ENV['LAYER_XCPRETTY_PARAMS'] || '')
    t.output_log = 'xcodebuild.log'
    t.env["LAYER_TEST_HOST"] = (ENV['LAYER_TEST_HOST'] || '10.66.0.35')
    t.subtasks = { unit: 'Unit Tests'}

    if ENV['LAYER_TESTING_DEVICE_ID']
      t.subtask :device do |s|
        s.sdk = 'iphoneos'
        s.scheme = 'Functional Tests'

        # Run the test on the device specified in the environment.
        s.destination platform: :ios, id: ENV['LAYER_TESTING_DEVICE_ID']
      end
    end
  end
end

task :ensure_ports_are_open do
  require 'socket'

  test_host = ENV['LAYER_TEST_HOST'] || '10.66.0.35'
  spdy_port = Integer(ENV['LAYER_TEST_SPDY_PORT'] || 9092)
  ctrl_port = Integer(ENV['LAYER_TEST_CONTROL_PORT'] || 7072)

  [spdy_port, ctrl_port].each do |port|
    begin
      TCPSocket.open test_host, port
    rescue Exception => ex
      abort("Unable to run tests: Failed connecting to #{test_host}:#{port} (#{ex})")
    end
  end
end

task :remove_project_schemes do
  if ENV['JENKINS_HOME']
    puts "Jenkins environment detected: removing xcuserdata directories"
    FileUtils::Verbose.rm_rf "LayerKit.xcodeproj/xcuserdata"
    FileUtils::Verbose.rm_rf "LayerKit.xcworkspace/xcuserdata"
  end
end

task default: :test

# Safe to run when Bundler is not available
def with_clean_env(&block)
  if defined?(Bundler)
    Bundler.with_clean_env(&block)
  else
    yield
  end
end

def run(command)
  puts "Executing `#{command}`"
  unless with_clean_env { system(command) }
    fail("Command exited with non-zero exit status (#{$?}): `#{command}`")
  end
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

def red(string)
  "\033[0;31m\!\! #{string}\033[0m"
end

def project_root
  File.expand_path(File.dirname(__FILE__))
end

def layerkit_version
  path = File.join(File.dirname(__FILE__), 'LayerKit.podspec')
  version = File.read(path).match(/\.version\s+=\s+['"](.+)['"]$/)[1]
end

desc "Prints the current version of LayerKit"
task :version do
  puts layerkit_version
end

namespace :version do
  desc "Sets the version by updating LayerKit.podspec and Code/LayerKit.m"
  task :set => :fetch_origin do
    version = ENV['VERSION']
    if version.nil? || version == ''
      fail "You must specify a VERSION"
    end

    existing_tag = `git tag -l v#{version}`.chomp
    if existing_tag != ''
      fail "A tag already exists for version v#{version}: please specify a unique release version."
    end

    podspec_path = File.join(File.dirname(__FILE__), 'LayerKit.podspec')
    podspec_content = File.read(podspec_path)
    unless podspec_content.gsub!(/(\.version\s+=\s+)['"](.+)['"]$/, "\\1'#{version}'")
      raise "Unable to update version of Podspec: version attribute not matched."
    end
    File.open(podspec_path, 'w') { |f| f << podspec_content }

    layerkit_m_path = File.join(File.dirname(__FILE__), 'Code', 'LayerKit.m')
    layerkit_m_content = File.read(layerkit_m_path)
    unless layerkit_m_content.gsub!(/(LYRSDKVersionString\s+=\s+@\")(.+)(\";)/, "\\1#{version}\\3")
      raise "Unable to update LYRSDKVersionString in #{layerkit_m_path}: version string not matched."
    end
    File.open(layerkit_m_path, 'w') { |f| f << layerkit_m_content }

    run "git add LayerKit.podspec Code/LayerKit.m"

    require 'highline/import'
    system("git diff --cached") if agree("Review package diff? (y/n) ")
    system("bundle exec pod update") if agree("Run `pod update`? (y/n) ")
    system("git commit -m 'Updating version to #{version}' LayerKit.podspec Code/LayerKit.m Podfile.lock") if agree("Commit package artifacts? (y/n) ")
  end
end

namespace :release do
  desc "Builds a release package"
  task :build => [:ensure_dropbox_path, :fetch_origin] do
    with_clean_env do
      path = File.join(File.dirname(__FILE__), 'LayerKit.podspec')
      version = File.read(path).match(/\.version\s+=\s+['"](.+)['"]$/)[1]
      puts green("Building LayerKit v#{version}")

      layer_kit_source = File.read(File.join(File.dirname(__FILE__), 'Code', 'LayerKit.m'))
      unless layer_kit_source =~ /LYRSDKVersionString \= \@\"#{Regexp.escape version}\"/
        puts red("Build failed: `LYRSDKVersionString` != #{version}. Looks like you forgot to update Code/LayerKit.m")
        exit -1
      end

      changelog = File.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md'))
      version_prefix = version.gsub(/-[\w\d]+/, '')
      puts "Checking for #{version_prefix}"
      unless changelog =~ /^## #{version_prefix}/
        fail "Unable to locate CHANGELOG section for version #{version}"
      end

      existing_tag = `git tag -l v#{version}`.chomp
      if existing_tag != ''
        fail "A tag already exists for version v#{version}: Maybe you need to run `rake version:set`?"
      end

      puts green("Tagging LayerKit v#{version}")
      run("git tag v#{version}")
      run("git push origin --tags")

      run "bundle exec pod package --spec-sources=git@github.com:layerhq/cocoapods-specs.git,https://github.com/CocoaPods/Specs.git --mangle --embedded --force LayerKit.podspec"
      if $?.exitstatus.zero?
        puts "Configuring podspec..."
        framework_ext = 'embeddedframework'
        path = File.join(File.dirname(__FILE__), "LayerKit-#{version}", "LayerKit.podspec")
        content = File.read(path)
        content.gsub!("s.source = {}", 's.source = { git: \'https://github.com/layerhq/releases-ios.git\', tag: "v#{s.version}" }')
        content.gsub!("s.homepage = 'https://github.com/layerhq/LayerKit'", "s.homepage = 'http://layer.com'")
        content.gsub!("ios/LayerKit.#{framework_ext}", "LayerKit.#{framework_ext}")
        File.open(path, 'w') { |f| f << content }
        puts "Moving build into Releases/"
        run "[ -d Releases/LayerKit-#{version} ] && rm -rf Releases/LayerKit-#{version}; true"
        run "mkdir -p Releases/LayerKit-#{version}"
        run "mv LayerKit-#{version}/ios/LayerKit.#{framework_ext} Releases/LayerKit-#{version}/LayerKit.#{framework_ext}"
        run "mv LayerKit-#{version}/LayerKit.podspec Releases/LayerKit-#{version}/LayerKit.podspec"
        run "cp CHANGELOG.md Releases/LayerKit-#{version}/CHANGELOG.md"
        run "rm -rf LayerKit-#{version}"
        puts green("LayerKit v#{version} built to Releases/")

        puts "Publishing build to Dropbox archives"
        dropbox_path = File.expand_path('~/Dropbox/Layer/Builds/iOS/')
        run "rsync -aP Releases/LayerKit-#{version} #{dropbox_path}"

        require 'slack-notifier'
        notifier = Slack::Notifier.new "layer", "IBYcWAHe4H4CEKLKUUJkzkAf"
        notifier.ping "Good news everyone! LayerKit v#{version} is now available on Dropbox", channel: '#dev', username: 'LayerBot', icon_emoji: ":goodnewseveryone:"
      end
    end
  end

  desc "Pushes a release package onto the release repositories"
  task :push => [:ensure_dropbox_path, :fetch_origin] do
    root_dir = File.expand_path(File.dirname(__FILE__))
    path = File.join(root_dir, 'LayerKit.podspec')
    version = File.read(path).match(/\.version\s+=\s+['"](.+)['"]$/)[1]
    existing_tag = `git tag -l v#{version}`.chomp
    fail "Unable to find tag v#{version}" unless existing_tag

    Rake::Task["release:build"].invoke unless File.exists?("Releases/LayerKit-#{version}")

    cache_dir = File.expand_path('~/Library/Caches/com.layer.LayerKit')
    run "mkdir -p #{cache_dir}" unless File.exists?(cache_dir)
    release_dir = File.join(cache_dir, 'releases-ios')
    unless File.exists?(release_dir)
      run "git clone git@github.com:layerhq/releases-ios.git #{release_dir}"
    end

    puts green("Pushing framework to layerhq/releases-ios")
    changelog = File.join(root_dir, 'CHANGELOG.md')
    podspec = File.join(root_dir, 'Releases', "LayerKit-#{version}", "LayerKit.podspec")
    framework = File.join(root_dir, 'Releases', "LayerKit-#{version}", "LayerKit.embeddedframework")
    Dir.chdir(release_dir) do
      run "git fetch origin && git reset --hard origin/master"
      run "cp #{podspec} #{release_dir}/LayerKit.podspec"
      run "rsync -avp --delete #{framework} #{release_dir}"
      run "cp #{changelog} #{release_dir}/CHANGELOG.md"
      run "git add LayerKit.embeddedframework CHANGELOG.md LayerKit.podspec"
      run "git commit -am 'Publishing LayerKit v#{version}'"
      run "git tag v#{version}"
      run "git push origin master --tags"
    end
    with_clean_env do
      puts green("Pushing podspec to layerhq/releases-cocoapods")
      run("[ -d ~/.cocoapods/repos/layer-releases ] || rbenv exec bundle exec pod repo add layer-releases git@github.com:layerhq/releases-cocoapods.git")
      run "bundle exec pod repo push layer-releases #{podspec}"

      puts green("Pushing podspec to CocoaPods trunk")
      run "pod trunk push #{podspec}"
    end

    require 'slack-notifier'
    notifier = Slack::Notifier.new "layer", "IBYcWAHe4H4CEKLKUUJkzkAf"
    notifier.ping "Good news everyone! LayerKit v#{version} has been released on [Github](https://github.com/layerhq/releases-ios) and [CocoaPods](https://github.com/CocoaPods/Specs/tree/master/Specs/LayerKit)", channel: '#dev', username: 'LayerBot', icon_emoji: ":goodnewseveryone:"

    Rake::Task["docs"].invoke
  end

  task :ensure_dropbox_path do
    dropbox_path = ENV['LAYER_DROPBOX_PATH'] || '~/Dropbox (Layer)'
    unless File.exists?(File.expand_path(dropbox_path))
      puts red "Unable to find Dropbox builds directory at '#{dropbox_path}'. You need access in order to cut QA builds. If you Dropbox path is different then export the LAYER_DROPBOX_PATH environment variable to configure it."
      exit 1
    end
  end
end

task :fetch_origin do
  run "git fetch origin --tags"
end

desc "Generate API documentation"
task :docs do
  # puts green("Generating API documentation...")
  run "Resources/Executables/appledocJson --project-name LayerKit --project-company Layer -x Code/Private -i Code/Private Code/*.h"

  # Push bits into docs repo
  cache_dir = File.expand_path('~/Library/Caches/com.layer.LayerKit')
  run "mkdir -p #{cache_dir}" unless File.exists?(cache_dir)
  docs_dir = File.join(cache_dir, 'documentation')
  unless File.exists?(docs_dir)
    run "git clone git@github.com:layerhq/documentation.git #{docs_dir}"
  end

  docs_generated = true
  puts green("Pushing docs to layerhq/documentation")
  Dir.chdir(docs_dir) do
    run "git fetch origin && git reset --hard origin/master"
    run "cp ~/appledoc.json api/ios/latest/data.json"
    run "git add api/ios/latest/data.json"
    `test -z "$(git status --porcelain)"`
    docs_generated = ($?.exitstatus > 0)
    if docs_generated
      run "git commit -am 'Updating iOS API docs for LayerKit v#{layerkit_version}'"
      run "git push origin master"
    end
  end

  if !docs_generated
    puts green("No documentation changes were encountered.")
    exit
  end

  require 'slack-notifier'
  notifier = Slack::Notifier.new "layer", "IBYcWAHe4H4CEKLKUUJkzkAf"
  notifier.ping "Good news everyone! LayerKit v#{layerkit_version} API documentation has been pushed to [Github](https://github.com/layerhq/documentation)", channel: '#dev', username: 'LayerBot', icon_emoji: ":goodnewseveryone:"

  # Harass Nil and Drew about releasing the docs
  require 'sendgrid-ruby'

  # As a hash
  client = SendGrid::Client.new(api_user: 'layer', api_key: 'l4y3r2013mission')
  mail = SendGrid::Mail.new do |m|
    m.to = %w{drew@layer.com nil@layer.com}
    m.from = 'applications-ios@layer.com'
    m.subject = "ATTN: Please Publish LayerKit v#{layerkit_version} Documentation"
    m.text = "Refreshed docs have been published to https://github.com/layerhq/documentation. Please deploy them!\n\n"
  end
  client.send(mail)

  puts green("Deployment reminder email sent to #{mail.to.join(', ')}.")
end
