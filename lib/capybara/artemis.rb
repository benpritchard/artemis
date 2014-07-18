require "capybara/artemis/version"
require 'capybara'

module Capybara
  module Artemis
    require 'capybara/artemis/request'
    require 'capybara/artemis/response'
    require 'capybara/artemis/node'
    require 'capybara/artemis/browser'
    require 'capybara/artemis/driver'
  end
end

Capybara.register_driver :artemis do |app|
  Capybara::Artemis::Driver.new(app)
end