# frozen_string_literal: true

require 'telegram/bot'
require_relative 'gemini_client'
require_relative 'access_control'
require_relative 'goiabook_client'
require_relative 'api_listener'

module Pessegram
  class Bot
    def initialize(token, master_id, gemini_key, persona_path, goiabook_config = {}, gemini_model = 'gemini-2.0-flash')
      @token = token
      @access_control = AccessControl.new(master_id)
      persona_raw = File.read(persona_path).force_encoding('UTF-8')
      persona_interpolated = (persona_raw % { master_id: master_id }).force_encoding('UTF-8')
      @gemini = GeminiClient.new(gemini_key, persona_interpolated, gemini_model)
      @memory = Memory.new(10) # 5 do usuário + 5 do modelo
      @goiabook = (goiabook_config[:url] && goiabook_config[:token]) ? GoiabookClient.new(goiabook_config[:url], goiabook_config[:token]) : nil
    end

    def run
      Telegram::Bot::Client.run(@token) do |bot|
        puts "Pollux (Pessegram) está online e vigiando o caos..."

        # LIGA O OUVINTE AQUI! Passando o 'bot' para ele poder falar
        Pessegram::ApiListener.start(bot)
        
        bot.listen do |message|
          case message
          when Telegram::Bot::Types::Message
            # Caso o bot seja adicionado a um grupo
            if message.new_chat_members&.any? { |member| member.username == bot.api.get_me['result']['username'] }
              puts "Fui adicionado ao grupo #{message.chat.title} (#{message.chat.id}). Retirando-se imediatamente..."
              bot.api.leave_chat(chat_id: message.chat.id)
              next
            end

            next unless message.text
            handle_message(bot, message)
          end
        end
      end
    rescue StandardError => e
      puts "Ocorreu um erro catastrófico no bot: #{e.message}"
      sleep 5
      retry
    end

    private

    def handle_message(bot, message)
      user_id = message.from.id
      
      unless @access_control.authorized?(user_id)
        return
      end

      case message.text
      when '/start'
        @memory.clear
        bot.api.send_message(chat_id: message.chat.id, text: "Saudações, meu mestre. O Pessegram está ativo. Memória limpa. O que falhou hoje?")
      when %r{https?://\S+}
        url = Regexp.last_match(0)
        # Se tem link, salva na Goiaba e ponto final. O Gemini não deve ser perturbado.
        save_link(bot, message, url, silent: false)
      else
        history = @memory.get_history
        response = @gemini.generate_response(message.text, history: history)
        
        @memory.add('user', message.text)
        @memory.add('model', response)
        
        bot.api.send_message(chat_id: message.chat.id, text: response)
      end
    end

    def save_link(bot, message, url, silent: false)
      return bot.api.send_message(chat_id: message.chat.id, text: "GoiabookLM não configurado, mestre.") unless @goiabook

      @goiabook.post_bookmark(url)
      bot.api.send_message(chat_id: message.chat.id, text: "Link enviado para o GoiabookLM com sucesso!") unless silent
    rescue GoiabookClient::Error => e
      bot.api.send_message(chat_id: message.chat.id, text: e.message) unless silent
      puts "#{e.message}"
    end
  end
end
