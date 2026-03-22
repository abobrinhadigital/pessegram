# frozen_string_literal: true

require_relative '../../lib/shared/base_bot'
require_relative 'mangofier_client'

module Pessegram
  module Mangofier
    class Bot < BaseBot
      def initialize(token:, master_id:, mangofier_url:, mangofier_token:)
        super(token: token, bot_name: 'mangofier', master_id: master_id)

        @mangofier_client = MangofierClient.new(mangofier_url, mangofier_token)
        @waiting_for_mu_link = false
      end

      def handle_update(update)
        message = update['message']
        return unless message

        chat_id = message['chat']['id']
        user_id = message['from']['id']
        text = message['text']

        return unless text
        return unless authorized?(user_id)

        # Verificar se é resposta a uma mensagem do bot (mapeamento)
        if message['reply_to_message']&.dig('from', 'is_bot')
          original_text = message['reply_to_message']['text'].to_s

          if original_text.include?('MU:')
            handle_mapeamento_reply(message, chat_id, original_text)
            return
          end
        end

        # Comando /mapear
        case text
        when %r{^/mapear\s+(https?://\S+)}
          handle_mapear_command(Regexp.last_match(1), chat_id)
        when '/mapear'
          send_message('Mestre, para usar o mapeamento ativo, digite: `/mapear [LINK_DO_MANGAUPDATES]`',
                       chat_id: chat_id)
        end
      end

      private

      def handle_mapear_command(url_mu, _chat_id)
        Thread.new do
          @mangofier_client.mapear_link(url_mu)
        rescue StandardError => e
          puts "[Mangofier Bot] Erro ao iniciar mapeamento: #{e.message}"
        end
      end

      def handle_mapeamento_reply(message, _chat_id, original_text)
        url = message['text']
        return unless url&.match?(%r{https?://\S+})

        Thread.new do
          @mangofier_client.post_link(url, context: original_text)
        rescue StandardError => e
          puts "[Mangofier Bot] Erro ao encaminhar link: #{e.message}"
        end
      end
    end
  end
end
