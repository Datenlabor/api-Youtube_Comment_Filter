# frozen_string_literal: true

%w(entities mappers repositories values)
  .each do |folder|
    require_relative "#{folder}/init"
  end
