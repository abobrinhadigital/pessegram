# frozen_string_literal: true

require 'json'

module Pessegram
  class WebhookRouter
    def initialize
      @routes = {}
    end

    def register(path, bot_instance)
      @routes[path] = bot_instance
    end

    def handle(path, update_data)
      bot = @routes[path]
      return nil unless bot

      bot.handle_update(update_data)
    end

    def routes
      @routes.keys
    end
  end
end
