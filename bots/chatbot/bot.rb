# frozen_string_literal: true

require_relative '../../lib/shared/base_bot'
require_relative 'gemini_client'
require_relative 'memory'
require_relative 'access_control'

module Pessegram
  module Chatbot
    class Bot < BaseBot
      def initialize(token:, master_id:, gemini_api_key:, gemini_model: 'gemini-2.5-flash-lite', persona_path: nil)
        super(token: token, bot_name: 'chatbot', master_id: master_id)

        @access_control = AccessControl.new(master_id)
        @memory = Memory.new(10)

        persona = persona_path ? File.read(persona_path).force_encoding('UTF-8') : default_persona
        @gemini = GeminiClient.new(gemini_api_key, persona, gemini_model)
      end

      def handle_update(update)
        puts '[Chatbot] handle_update chamado'
        message = update['message']
        return unless message

        chat_id = message['chat']['id']
        user_id = message['from']['id']
        text = message['text']

        puts "[Chatbot] chat_id=#{chat_id}, user_id=#{user_id}, text=#{text}"

        # Verificar se é um bot adicionado a grupo
        if message['new_chat_members']&.any? { |m| m['is_bot'] }
          puts 'Bot adicionado a grupo. Ignorando...'
          return
        end

        return unless text

        puts "[Chatbot] authorized? #{authorized?(user_id)}"
        return unless authorized?(user_id)

        handle_command(chat_id, text)
      end

      private

      def handle_command(chat_id, text)
        case text
        when '/start'
          @memory.clear
          send_message('Saudações, meu mestre. O Chatbot está ativo. Memória limpa.', chat_id: chat_id)
        else
          history = @memory.get_history
          response = @gemini.generate_response(text, history: history)

          @memory.add('user', text)
          @memory.add('model', response)

          send_message(response, chat_id: chat_id)
        end
      end

      def default_persona
        'Você é um assistente prestativo e sarcástico.'
      end
    end
  end
end
