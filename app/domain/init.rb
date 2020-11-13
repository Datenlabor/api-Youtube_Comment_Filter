# frozen_string_literal: true

folders = %w[videos comments]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
