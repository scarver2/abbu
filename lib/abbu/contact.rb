# lib/abbu/contact.rb
# frozen_string_literal: true

module Abbu
  class Contact
    attr_accessor :first_name, :last_name, :emails, :phones, :company

    def initialize
      @emails = []
      @phones = []
    end

    def full_name
      [first_name, last_name].compact.join(' ')
    end

    def to_s
      "#<Abbu::Contact first_name=#{first_name.inspect} last_name=#{last_name.inspect} " \
        "emails=#{emails.inspect} phones=#{phones.inspect}>"
    end

    def inspect
      to_s
    end
  end
end
