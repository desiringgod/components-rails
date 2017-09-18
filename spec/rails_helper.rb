# frozen_string_literal: true

require 'spec_helper'

require 'rails'
# require 'active_record/railtie'
require 'active_support/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
# require 'action_mailer/railtie'
# require 'active_job/railtie'
# require 'action_cable/engine'
require 'rails/test_unit/railtie'
# require 'sprockets/railtie'

ENV['RAILS_ENV'] ||= 'test'
class ApplicationController < ActionController::Base; end

require 'components-rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir['./spec/support/**/*.rb'].each { |f| require f }
