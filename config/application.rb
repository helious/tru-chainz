require File.expand_path('../boot', __FILE__)

require 'rails'
require 'action_controller/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

#require 'json'
#require 'httparty'
#require 'fuzzystringmatch'

module TruChainz
  class Application < Rails::Application
  end
end
