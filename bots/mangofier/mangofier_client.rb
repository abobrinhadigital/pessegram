# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Pessegram
  module Mangofier
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

        send_request(request)
      end

      def mapear_link(url_mu)
        uri_mapear = @url.dup
        uri_mapear.path = '/mapearlink'

        request = Net::HTTP::Post.new(uri_mapear.path, {
                                        'Content-Type' => 'application/json',
                                        'Authorization' => "Bearer #{@token}"
                                      })

        request.body = { mensagem: url_mu }.to_json

        send_request(request)
      end

      private

      def send_request(request)
        response = Net::HTTP.start(@url.host, @url.port, use_ssl: @url.scheme == 'https') do |http|
          http.open_timeout = 5
          http.read_timeout = 5
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          error_body = response.body.to_s.force_encoding('UTF-8')
          raise Error, "Erro no Mangofier: #{response.code} - #{error_body}"
        end

        true
      rescue StandardError => e
        raise Error, "Falha na comunicação com Mangofier: #{e.message.force_encoding('UTF-8')}"
      end
    end
  end
end
