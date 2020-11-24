require_relative 'init'

yt_video = GetComment::Youtube::VideoMapper.new('AIzaSyAR8RHw5od5S89jwWgpcpGB8z2hSWXpGfw').extract('SGMHrFEs-KM')
video = GetComment::Repository::For.entity(yt_video).create(yt_video)
yt_comment = GetComment::Youtube::CommentMapper.new('AIzaSyAR8RHw5od5S89jwWgpcpGB8z2hSWXpGfw').extract('SGMHrFEs-KM')
#video = GetComment::Repository::For.entity(yt_video).create(yt_video)
GetComment::Repository::For.klass(Entity::Comment)
                               .create_many_of_one_video(yt_comments,
                                                         video.video_db_id)
