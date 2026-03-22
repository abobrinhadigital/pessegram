# frozen_string_literal: true

module Pessegram
  module Chatbot
    class AccessControl
      def initialize(master_id)
        @master_id = master_id.to_i
      end

      def authorized?(user_id)
        user_id.to_i == @master_id
      end
    end
  end
end
