require 'webmock/rspec'
require 'dotenv'
require_relative '../lib/groovehq'
require_relative './groovehq/support/factories'

Dotenv.load

RSpec.configure do |config|
  config.before :all do
    WebMock.enable!
  end

  config.before :all, integration: true do
    WebMock.disable!
  end

  config.include Factories, integration: true
end
