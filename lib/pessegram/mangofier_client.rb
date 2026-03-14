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

    def post_link(url)
      request = Net::HTTP::Post.new(@url.path, {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@token}"
      })
      request.body = { mensagem: url }.to_json

      response = Net::HTTP.start(@url.host, @url.port, use_ssl: @url.scheme == 'https') do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Erro no Mangofier: #{response.code} - #{response.body}"
      end
    rescue StandardError => e
      raise Error, "Falha na comunicação com Mangofier: #{e.message}"
    end
  end
end
