# frozen_string_literal: true

module GetComment
  module Value
    # Define a Analysis class to analyze polarity
    class Analysis
      def initialize(comment)
        @comment = comment
      end

      # https://stackoverflow.com/questions/690151/getting-output-of-system-calls-in-ruby/690174#690174
      def polarity
        @comment = DataProcessing.new(@comment).remove_html_tags
        output = `python3 app/infrastructure/lib/ml_algo.py #{@comment}`
        output.gsub('\n', '').to_f
      end

      # Remove the html tags in this class
      class DataProcessing
        def initialize(comment)
          @comment = comment
        end

        def remove_html_tags
          re = /<("[^"]*"|'[^']*'|[^'">])*>/
          @comment = @comment.gsub(re, '')
        end
      end
    end
  end
end
