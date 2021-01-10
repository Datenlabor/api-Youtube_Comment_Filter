# frozen_string_literal: true

module GetComment
  module Value
    # Define a Analysis class to analyze polarity
    class Analysis
      def initialize(comment)
        @comment = comment
        @filename = "app/domain/videos/mappers/temp/#{Time.new.strftime('%H_%M_%S_%L')}.txt"
      end

      # https://stackoverflow.com/questions/690151/getting-output-of-system-calls-in-ruby/690174#690174
      def polarity
        # @comment = DataProcessing.new(@comment).remove_html_tags
        # output = `python3 app/infrastructure/lib/ml_algo.py #{@comment}`
        # output.gsub('\n', '').to_f
        DataProcessing.new(@comment, @filename).writetxt
        output_f = `python3 app/infrastructure/lib/ml_algo.py #{@filename}`
        output_f.delete!("\n")
        result = GettingResult.new(output_f).readtxt
        DeletectionFile.new(@filename, output_f).deletection
        result
      end

      # Remove the html tags in this class
      class DataProcessing
        def initialize(comment, filename)
          @comment = comment
          @filename = filename
        end

        def writetxt
          puts '==DEBUG== Starts writing file'
          out_file = File.new(@filename, 'w')
          out_file.puts(@comment)
          out_file.close
          puts '==DEBUG== Finish writing file'
        end

        def remove_html_tags
          re = /<("[^"]*"|'[^']*'|[^'">])*>/
          @comment = @comment.gsub(re, '')
        end
      end

      # Getting the return polarity from output_f file
      class GettingResult
        def initialize(output_f)
          @output_f = File.open(output_f).read # Return value have some strange char in it.
        end

        def readtxt
          polarity_list = []
          @output_f.each_line do |line|
            polarity_list.append(line.delete("\n").to_f)
          end
          polarity_list
        end
      end

      # Delete temp files
      class DeletectionFile
        def initialize(file_a, file_b)
          @file_a = file_a
          @file_b = file_b
        end

        def deletection
          `rm #{@file_a}`
          `rm #{@file_b}`
        end
      end
    end
  end
end
