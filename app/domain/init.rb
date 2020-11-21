# frozen_string_literal: true

folders = %w[videos]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
