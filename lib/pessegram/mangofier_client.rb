# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Pessegram
  class MangofierClient
    class Error < StandardError; end

    def initialize(url, token)
      @url = URI.parse(url)
      @token = token
    end

    def post_link(url, context: nil)
      request = Net::HTTP::Post.new(@url.path, {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@token}"
      })
      
      payload = { mensagem: url }
      payload[:contexto] = context if context
      
      request.body = payload.to_json

      response = Net::HTTP.start(@url.host, @url.port, use_ssl: @url.scheme == 'https') do |http|
        http.open_timeout = 5 # 5 segundos para conectar
        http.read_timeout = 5 # 5 segundos para ler a resposta
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        # Forçamos UTF-8 para evitar o erro de BINARY/ASCII-8BIT
        error_body = response.body.to_s.force_encoding('UTF-8')
        raise Error, "Erro no Mangofier: #{response.code} - #{error_body}"
      end
    rescue StandardError => e
      raise Error, "Falha na comunicação com Mangofier: #{e.message.to_s.force_encoding('UTF-8')}"
    end
  end
end
