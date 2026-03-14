# frozen_string_literal: true

require 'telegram/bot'
require_relative 'gemini_client'
require_relative 'access_control'
require_relative 'goiabook_client'
require_relative 'api_listener'
require_relative 'mangofier_client'

module Pessegram
  class Bot
    def initialize(token, master_id, gemini_key, persona_path, goiabook_config = {}, gemini_model = 'gemini-2.0-flash', mangofier_config = {})
      @token = token
      @access_control = AccessControl.new(master_id)
      persona_raw = File.read(persona_path).force_encoding('UTF-8')
      persona_interpolated = (persona_raw % { master_id: master_id }).force_encoding('UTF-8')
      @gemini = GeminiClient.new(gemini_key, persona_interpolated, gemini_model)
      @memory = Memory.new(10) # 5 do usuário + 5 do modelo
      @goiabook = (goiabook_config[:url] && goiabook_config[:token]) ? GoiabookClient.new(goiabook_config[:url], goiabook_config[:token]) : nil
      @mangofier = (mangofier_config[:url] && mangofier_config[:token]) ? MangofierClient.new(mangofier_config[:url], mangofier_config[:token]) : nil
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
        
        # Se for um link em uma RESPOSTA a uma mensagem do bot que contém "MU:", manda pro Mangofier
        if message.reply_to_message && message.reply_to_message.from.is_bot && message.reply_to_message.text&.include?("MU:")
          forward_to_mangofier(bot, message, url)
        else
          # Se não for resposta, salva na Goiaba e ponto final. O Gemini não deve ser perturbado.
          save_link(bot, message, url, silent: false)
        end
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

    def forward_to_mangofier(bot, message, url)
      return bot.api.send_message(chat_id: message.chat.id, text: "MangofierService não configurado, mestre.") unless @mangofier

      @mangofier.post_link(url)
      puts "🥭 Mangofier: Link '#{url}' encaminhado com sucesso!"
      # bot.api.send_message(chat_id: message.chat.id, text: "Link encaminhado para o mangofier_service com sucesso! 🥭")
    rescue MangofierClient::Error => e
      bot.api.send_message(chat_id: message.chat.id, text: "Falha ao enviar para o Mangofier: #{e.message}")
      puts "#{e.message}"
    end
  end
end
