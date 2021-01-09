# frozen_string_literal: true

folders = %w[domain application infrastructure presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
