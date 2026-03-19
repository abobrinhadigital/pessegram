# lib/api_listener.rb
require 'webrick'
require 'json'

module Pessegram
  class ApiListener
    @server = nil

    def self.start(telegram_bot)
      # Desliga server anterior se existir (evita "Address already in use")
      stop

      port = (ENV['LISTENER_API_PORT'] || 7355).to_i
      token = ENV['LISTENER_API_TOKEN']

      # Porta 0 = OS escolhe uma disponível (evita conflito em desenvolvimento)
      # Para porta fixa, remova a condição abaixo
      actual_port = port == 0 ? 0 : port

      @server = WEBrick::HTTPServer.new(
        Port: actual_port,
        AccessLog: [],
        Logger: WEBrick::Log.new(File::NULL)
      )

      # O endpoint universal de comunicação
      @server.mount_proc '/falar' do |req, res|
        auth_header = req.header['authorization']&.first

        if req.request_method == 'POST' && auth_header == "Bearer #{token}"
          begin
            payload = JSON.parse(req.body)
            mensagem = payload['mensagem']

            if mensagem.nil? || mensagem.empty?
              res.status = 400
              res.body = { erro: 'O payload precisa conter o campo "mensagem" preenchido.' }.to_json
            else
              telegram_bot.api.send_message(
                chat_id: ENV['MASTER_USER_ID'],
                text: mensagem
              )

              res.status = 200
              res.body = { status: 'ok', info: 'Grito ecoado no Telegram com sucesso!' }.to_json
            end
          rescue StandardError => e
            res.status = 400
            res.body = { erro: "Falha ao processar o payload: #{e.message}" }.to_json
          end
        else
          res.status = 401
          res.body = { erro: 'Acesso negado. Mostre o token ou dê meia-volta.' }.to_json
        end
      end

      Thread.new do
        @server.start
        puts "🎧 API Listener a escutar nas sombras pela porta #{@server.port}..."
      end
    end

    def self.stop
      return unless @server

      @server.shutdown
      @server = nil
    end
  end
end
