# frozen_string_literal: true

module Pessegram
  class AccessControl
    def initialize(master_id)
      @master_id = master_id.to_i
    end

    def authorized?(user_id)
      user_id.to_i == @master_id
    end

    def error_message
      "Quem é você? Eu só obedeço ao meu mestre Marcelo. Saia da frente antes que a Lei de Murphy te atinja."
    end
  end
end
