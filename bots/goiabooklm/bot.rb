# frozen_string_literal: true

require_relative '../../lib/shared/base_bot'
require_relative 'goiabook_client'
require_relative 'link_detector'

module Pessegram
  module GoiabookLM
    class Bot < BaseBot
      def initialize(token:, master_id:, api_url:, api_token:, api_router:)
        super(token: token, bot_name: 'goiabooklm', master_id: master_id)

        @goiabook_client = GoiabookClient.new(api_url, api_token)
        @link_detector = LinkDetector.new
        @api_router = api_router
      end

      def handle_update(update)
        message = update['message']
        return unless message

        chat_id = message['chat']['id']
        user_id = message['from']['id']
        text = message['text']

        return unless text
        return unless authorized?(user_id)

        # Verificar se é resposta a uma mensagem do bot (para mapeamento)
        if message['reply_to_message']&.dig('from', 'is_bot')
          handle_reply(message, chat_id)
          return
        end

        # Detectar links
        if (url = @link_detector.extract(text))
          handle_link(url, chat_id)
        end
      end

      private

      def handle_link(url, chat_id)
        send_message('Link enviado para o GoiabookLM com sucesso!', chat_id: chat_id)

        Thread.new do
          @goiabook_client.post_bookmark(url)
        rescue StandardError => e
          puts "[GoiabookLM Bot] Erro: #{e.message}"
        end
      end

      def handle_reply(message, chat_id)
        # Lógica para lidar com respostas (mapeamento)
        # TODO: implementar lógica de mapeamento
      end
    end
  end
end
