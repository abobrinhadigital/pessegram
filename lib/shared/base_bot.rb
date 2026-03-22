# frozen_string_literal: true

require 'telegram/bot'

module Pessegram
  class BaseBot
    attr_reader :token, :bot_name

    def initialize(token:, bot_name:, master_id:)
      @token = token
      @bot_name = bot_name
      @master_id = master_id.to_i
      @api = nil
    end

    def handle_update(update)
      raise NotImplementedError, 'Subclasses must implement handle_update'
    end

    def send_message(text, chat_id:)
      puts "[DEBUG] send_message chamado: chat_id=#{chat_id}, text=#{text[0..50]}..."
      return unless @api

      begin
        result = @api.send_message(chat_id: chat_id, text: text)
        puts '[DEBUG] Mensagem enviada com sucesso'
        result
      rescue StandardError => e
        puts "[DEBUG] Erro ao enviar mensagem: #{e.message}"
        nil
      end
    end

    def authorized?(user_id)
      user_id.to_i == @master_id
    end

    def register_on(router)
      router.register(@bot_name, self)
    end

    def set_api(api)
      @api = api
    end
  end
end
