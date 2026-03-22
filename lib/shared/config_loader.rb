# frozen_string_literal: true

require 'yaml'
require 'dotenv/load'

module Pessegram
  class ConfigLoader
    def self.load
      {
        chatbot_token: ENV['TELEGRAM_BOT_TOKEN'],
        goiabooklm_token: ENV['GOIABOOKLM_BOT_TOKEN'],
        mangofier_token: ENV['MANGOFIER_BOT_TOKEN'],
        master_id: ENV['MASTER_USER_ID'],
        gemini_api_key: ENV['GEMINI_API_KEY'],
        gemini_model: ENV['GEMINI_MODEL'] || 'gemini-2.5-flash-lite',
        api_router_port: (ENV['LISTENER_API_PORT'] || 7355).to_i,
        api_router_token: ENV['LISTENER_API_TOKEN'],
        goiabook_api_url: ENV['GOIABOOK_API_URL'],
        goiabook_api_token: ENV['GOIABOOK_API_TOKEN'],
        mangofier_api_url: ENV['MANGOFIER_API_URL'],
        mangofier_api_token: ENV['MANGOFIER_API_TOKEN'],
        cloudflare_tunnel_id: ENV['CLOUDFLARE_TUNNEL_ID'],
        cloudflare_domain: ENV['CLOUDFLARE_DOMAIN'] || 'pessegram.mogami.dev.br'
      }
    end
  end
end
