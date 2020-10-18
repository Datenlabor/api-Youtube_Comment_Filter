# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'

# helper functions
def parse_data(data)
  { 'text' => data['topLevelComment']['snippet']['textDisplay'],
    'author' => data['topLevelComment']['snippet']['authorDisplayName'],
    'likeCount' => data['topLevelComment']['snippet']['likeCount'],
    'totalReplyCount' => data['totalReplyCount'],
    'replies' => [] }
end

def extract_data(rawdata)
  # All comments are in items
  data = {}
  comments = rawdata['items']
  comments.each do |comment|
    # We want id and snippet
    id = comment['id']
    snippet = comment['snippet']
    data.store(id, parse_data(snippet))
  end
  data
end

# 1. Set API_KEY, Select testcase
API_ROOT_URL = 'https://www.googleapis.com/youtube/v3/'
TEST_VIDEO_ID = 'DA8nk83xumg'
API_KEY = YAML.safe_load(File.read('config/secrets.yml'))['YT_KEY']
DEFAULT_OPTION = 'part=snippet&order=relevance'

# 2. http request and get response
request_comment_threads_url = "#{API_ROOT_URL}commentThreads?&key=#{API_KEY}&videoId=#{TEST_VIDEO_ID}&#{DEFAULT_OPTION}"
comment_threads_rawdata = HTTP.get(request_comment_threads_url).parse

# 3. parse the data into the following format: [{text, author, likeCount, totalReplyCount, replies[]}]
# reply is not retrieved during this step
comments_noreply = extract_data(comment_threads_rawdata)

# 4. get and parse the reply for each comment
comments = comments_noreply.map do |id, comment_info|
  request_replies_url = "#{API_ROOT_URL}comments?key=#{API_KEY}&parentId=#{id}&part=snippet"
  replies_rawdata = HTTP.get(request_replies_url).parse
  replies = replies_rawdata['items'].map { |reply| reply['snippet']['textDisplay'] }
  comment_info['replies'] = replies
  { id => comment_info }
end

output = File.open('./spec/fixtures/results.yml', 'w')
output << YAML.dump(comments)
output.close
