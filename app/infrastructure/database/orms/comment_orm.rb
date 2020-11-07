# frozen_string_literal: true

require 'sequel'

module GetComment
  module Database
    # Object-Relational Mapper for Comments
    class CommentOrm < Sequel::Model(:comments)
      many_to_one :video,
                  class: :'GetComment::Database::VideoOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
