$(document).ready(function($) {
    $(".video-card").click(function() {
        window.document.location = $(this).data("href");
    });
});

function onYouTubeIframeAPIReady() {
    var player;
    player = new YT.Player('YouTubeVideoPlayer', {
        videoId: $('#YouTubeVideoPlayer').data('obj'), // YouTube 影片ID
        width: 850, 
        height: 400, 
        playerVars: {
            autoplay: 1, // 在讀取時自動播放影片
            controls: 1, // 在播放器顯示暫停／播放按鈕
            showinfo: 0, // 隱藏影片標題
            modestbranding: 1, // 隱藏YouTube Logo
            loop: 1, // 讓影片循環播放
            fs: 0, // 隱藏全螢幕按鈕
            cc_load_policty: 0, // 隱藏字幕
            iv_load_policy: 3, // 隱藏影片註解
            autohide: 0 },
    });
}
