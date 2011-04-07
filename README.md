# Packaging rvm stuff for deployment

The overal goal of this project is to help with deploying ruby apps. Solved here is the problem of packaging an rvm-provided ruby. Steps in general:

* Forget about worrying about old versions of ruby.
* Package up whatever version of ruby with this project
* Package up your application (use bundler to vendor in the gem dependencies)
* Deploy both to production.

'package.sh' packages 'rvm' for deployment if you want it, not required to deploy.

'package-ruby.sh' packages any ruby you choose to install with rvm.

Requires fpm to package things. <https://github.com/jordansissel/fpm>

## Examle running with bundler deployment

These steps assume you already built the ruby package you wanted from the
examples further down on this page.

Assuming you wrote an app and ran 'bundle install --deployment' and are now
ready to deploy using ruby 1.9.2:

    % GEM_PATH=vendor/bundle/ruby/1.9.1/ /opt/rvm/rubies/ruby-1.9.2-p180/bin/ruby your-app.rb

## Example packaging jruby

    % bash package-ruby.sh jruby
    ...
    RVM not found; installing now to /home/jls/projects/rvm-packaging/build//opt/rvm
    ...
    WARN: jruby jruby-1.6.0 is not installed.
    To install do: 'rvm install jruby-1.6.0'
    jruby-1.6.0 - #fetching
    jruby-1.6.0 - #downloading jruby-bin-1.6.0, this may take a while depending on your connection...
    jruby-1.6.0 - #installing to /home/jls/projects/rvm-packaging/build//opt/rvm/rubies/jruby-1.6.0
    ...
    patching rvm scripts to remove path '/home/jls/projects/rvm-packaging/build/'
    Packaging up jruby-1.6.0
    Created /home/jls/projects/rvm-packaging/rvm-jruby_1.6.0-1_amd64.deb

    % sudo dpkg -i rvm-jruby_1.6.0-1_amd64.deb
    ...
    % /opt/rvm/wrappers/jruby-1.6.0/ruby -e 'puts [RUBY_PLATFORM, RUBY_VERSION].join("-")'
    java-1.8.7
    % /opt/rvm/wrappers/jruby-1.6.0/ruby --1.9 -e 'puts [RUBY_PLATFORM, RUBY_VERSION].join("-")'
    java-1.9.2


## Example packaging ruby 1.9.2

    % bash package-ruby.sh ruby-1.9.2
    ...
    ruby-1.9.2-p180 - #compiling
    ...
    patching rvm scripts to remove path '/home/jls/projects/rvm-packaging/build/'
    Packaging up ruby-1.9.2p180
    Created /home/jls/projects/rvm-packaging/rvm-ruby-1.9.2p180_1.9.2p180-1_amd64.deb

    % sudo dpkg -i rvm-ruby-1.9.2p180_1.9.2p180-1_amd64.deb
    ...

    % /opt/rvm/rubies/ruby-1.9.2-p180/bin/gem env
    RubyGems Environment:
      - RUBYGEMS VERSION: 1.3.7
      - RUBY VERSION: 1.8.7 (2010-06-23 patchlevel 299) [x86_64-linux]
      - INSTALLATION DIRECTORY: /opt/rvm/gems/ruby-1.9.2-p180
      - RUBY EXECUTABLE: /usr/bin/ruby1.8
      - EXECUTABLE DIRECTORY: /opt/rvm/gems/ruby-1.9.2-p180/bin
      - RUBYGEMS PLATFORMS:
        - ruby
        - x86_64-linux
      - GEM PATHS:
         - /opt/rvm/gems/ruby-1.9.2-p180
         - /opt/rvm/gems/ruby-1.9.2-p180@global
      - GEM CONFIGURATION:
         - :update_sources => true
         - :verbose => true
         - :benchmark => false
         - :backtrace => false
         - :bulk_threshold => 1000
      - REMOTE SOURCES:
         - http://rubygems.org/

