# frozen_string_literal: true

module FindComment
  # Infrastructure to finding comment while yielding progress
  module FindCommentMonitor
    FIND_PROGRESS = {
      'STARTED' => 15,
      'Get_Analyze_Comment' => 30,
      'Storing_Into_DB' => 70,
      'FINISHED' => 100
    }.freeze

    def self.starting_percent
      FIND_PROGRESS['STARTED'].to_s
    end

    def self.finished_percent
      FIND_PROGRESS['FINISHED'].to_s
    end

    def self.percent(stage)
      FIND_PROGRESS[stage].to_s
    end
  end
end
