# lib/abbu/contact.rb
# frozen_string_literal: true

module Abbu
  class Contact
    attr_accessor :first_name, :last_name, :emails, :phones, :company, :addresses, :groups, :nickname, :prefix, :suffix

    def initialize
      @emails = []
      @phones = []
      @addresses = []
      @groups = []
    end

    def full_name
      quoted_nickname = nickname ? "\"#{nickname}\"" : nil
      [prefix, first_name, quoted_nickname, last_name, suffix].compact.join(' ')
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
