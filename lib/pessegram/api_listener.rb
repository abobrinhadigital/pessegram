# lib/pessegram/api_listener.rb
require 'webrick'
require 'json'

class ApiListener
  def self.start(telegram_bot)
    # Agora a usar a sua nomenclatura padronizada
    port = (ENV['LISTENER_API_PORT'] || 7355).to_i
    token = ENV['LISTENER_API_TOKEN']

    # Servidor silencioso para não poluir o terminal do Pessegram
    server = WEBrick::HTTPServer.new(
      Port: port,
      AccessLog: [],
      Logger: WEBrick::Log.new(File::NULL)
    )

    # O endpoint universal de comunicação
    server.mount_proc '/falar' do |req, res|
      auth_header = req.header['authorization']&.first

      # 1. Verifica a procedência (A porta de segurança)
      if req.request_method == 'POST' && auth_header == "Bearer #{token}"
        begin
          payload = JSON.parse(req.body)
          mensagem = payload['mensagem']

          # 2. Valida se o conteúdo não é vazio
          if mensagem.nil? || mensagem.empty?
            res.status = 400
            res.body = { erro: 'O payload precisa conter o campo "mensagem" preenchido.' }.to_json
          else
            # 3. O Carteiro faz a entrega diretamente ao Mestre!
            telegram_bot.api.send_message(
              chat_id: ENV['MASTER_USER_ID'],
              text: mensagem
            )
            
            res.status = 200
            res.body = { status: 'ok', info: 'Grito ecoado no Telegram com sucesso!' }.to_json
          end
        rescue => e
          res.status = 400
          res.body = { erro: "Falha ao processar o payload: #{e.message}" }.to_json
        end
      else
        # 4. O bloqueio letal a intrusos
        res.status = 401
        res.body = { erro: 'Acesso negado. Mostre o token ou dê meia-volta.' }.to_json
      end
    end

    # Inicia a Thread paralela para não travar o loop do bot
    Thread.new do
      puts "API Listener a escutar nas sombras pela porta #{port}..."
      server.start
    end
  end
end