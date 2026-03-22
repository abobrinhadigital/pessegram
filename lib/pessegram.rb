# frozen_string_literal: true

require 'dotenv/load'

module Pessegram
  class Error < StandardError; end

  def self.persona_path
    File.expand_path('../../data/personas', __dir__)
  end
end

# Shared components
require_relative 'shared/base_bot'
require_relative 'shared/config_loader'
require_relative 'shared/api_router'
require_relative 'shared/webhook_router'

# Bots
require_relative '../bots/chatbot/bot'
require_relative '../bots/goiabooklm/bot'
require_relative '../bots/mangofier/bot'
