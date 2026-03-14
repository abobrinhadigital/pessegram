# frozen_string_literal: true

require 'thor'

module Pessegram
  class CLI < Thor
    desc "start", "Inicia o Pollux (Pessegram) no Telegram"
    def start
      token = ENV['TELEGRAM_BOT_TOKEN']
      master_id = ENV['MASTER_USER_ID']
      gemini_key = ENV['GEMINI_API_KEY']
      gemini_model = ENV['GEMINI_MODEL'] || 'gemini-2.0-flash'
      persona_path = Pessegram.persona_path

      mangofier_config = {
        url: ENV['MANGOFIER_API_URL'],
        token: ENV['MANGOFIER_API_TOKEN']
      }

      if [token, master_id, gemini_key].any? { |v| v.nil? || v.empty? }
        puts "ERRO: Faltam variáveis de ambiente no seu .env, mestre. Verifique o token e as chaves."
        exit 1
      end

      Pessegram::Bot.new(token, master_id, gemini_key, persona_path, goiabook_config, gemini_model, mangofier_config).run
    end

    desc "list-models", "Lista os modelos disponíveis no Google Gemini"
    def list_models
      gemini_key = ENV['GEMINI_API_KEY']
      if gemini_key.nil? || gemini_key.empty?
        puts "ERRO: GEMINI_API_KEY não encontrada no .env."
        exit 1
      end

      begin
        client = GeminiClient.new(gemini_key, "")
        result = client.list_models
        puts "Modelos disponíveis no Oráculo:"
        result["models"].each do |m|
          puts "- #{m['name'].gsub('models/', '')}: #{m['description']}"
        end
      rescue GeminiClient::Error => e
        puts "Falha técnica: #{e.message}"
      end
    end

    def self.exit_on_failure?
      true
    end
  end
end
