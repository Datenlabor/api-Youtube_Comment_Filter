require 'yaml'
#require_relative '../config/environment'
require_relative '../init'
ENV['RACK_ENV'] = 'test'

comment = GetComment::Youtube::VideoMapper.new.get_title('DA8nk83xumg')



File.open('demo.txt', 'w') do |file|
  comment.each {|k, v| file.write("#{k}: #{v}\n")}
end
