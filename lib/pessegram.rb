# frozen_string_literal: true

require 'dotenv/load'
require 'telegram/bot'
require_relative 'pessegram/version'
require_relative 'pessegram/gemini_client'
require_relative 'pessegram/access_control'
require_relative 'pessegram/goiabook_client'
require_relative 'pessegram/bot'
require_relative 'pessegram/memory'
require_relative 'pessegram/cli'
require_relative 'pessegram/api_listener'
require_relative 'pessegram/mangofier_client'

module Pessegram
  class Error < StandardError; end
  
  def self.persona_path
    File.expand_path('../data/ai_persona.md', __dir__)
  end
end
