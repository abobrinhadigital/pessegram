# frozen_string_literal: true

require 'puma'
require 'json'

module Pessegram
  class ApiRouter
    def initialize(port: 7355, token: nil)
      @port = port
      @token = token
      @bots = {}
    end

    def register_bot(name, bot_instance)
      @bots[name.to_sym] = bot_instance
    end

    def start
      require 'rack'

      app = ->(env) { handle_request(env) }

      @server = Puma::Server.new(app)
      @server.add_tcp_listener('0.0.0.0', @port)

      puts "🎧 API Router (Puma) rodando na porta #{@port}..."
      Thread.new { @server.run }
    end

    def stop
      @server&.stop
    end

    private

    def handle_request(env)
      request = Rack::Request.new(env)

      return unauthorized_response unless authorized?(request)

      case request.path_info
      when '/falar'
        handle_falar(request)
      when %r{^/bot/(.+)$}
        bot_name = ::Regexp.last_match(1)
        handle_bot_message(bot_name, request)
      else
        not_found_response
      end
    rescue StandardError => e
      puts "[API Router] Erro: #{e.message}"
      [500, { 'Content-Type' => 'application/json' }, [{ error: e.message }.to_json]]
    end

    def authorized?(request)
      # Webhooks do Telegram não enviam Authorization header
      # Autenticação via URL secreta (path contém hash) ou sem auth em desenvolvimento
      return true if @token.nil?

      # Verificar se há Authorization header
      auth_header = request.env['HTTP_AUTHORIZATION']
      return true if auth_header.nil? && request.path_info.match?(%r{^/bot/})

      auth_header == "Bearer #{@token}"
    end

    def handle_falar(request)
      payload = JSON.parse(request.body.read)
      mensagem = payload['mensagem']

      return bad_request_response('mensagem') unless mensagem

      # Enviar para master via Telegram direto (legado)
      # TODO: implementar envio direto
      [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok' }.to_json]]
    end

    def handle_bot_message(bot_name, request)
      bot = @bots[bot_name.to_sym]

      return not_found_response unless bot

      payload = JSON.parse(request.body.read)

      # Formato interno: { "mensagem": "...", "chat_id": "..." }
      # Formato Telegram: { "message": { "text": "...", "chat": { "id": "..." }, ... } }
      if payload['message']
        # Webhook do Telegram
        bot.handle_update(payload)
        [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', bot: bot_name }.to_json]]
      else
        # Formato interno (API)
        mensagem = payload['mensagem']
        chat_id = payload['chat_id'] || ENV['MASTER_USER_ID']

        return bad_request_response('mensagem') unless mensagem
        return bad_request_response('chat_id') unless chat_id

        bot.send_message(mensagem, chat_id: chat_id)

        [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', bot: bot_name }.to_json]]
      end
    end

    def unauthorized_response
      [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
    end

    def not_found_response
      [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
    end

    def bad_request_response(field)
      [400, { 'Content-Type' => 'application/json' }, [{ error: "Missing field: #{field}" }.to_json]]
    end
  end
end
