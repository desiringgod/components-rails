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
# require 'rspec/rails'

ENV['RAILS_ENV'] ||= 'test'
class ApplicationController < ActionController::Base; end

require 'components-rails'
