//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

window.currentPlayTime = 0
window.highlightLyricsInterval = null

currentTrack = null
isPause = false

pause = ->
  time = currentTrack.duration.split ':'

  minute = time[0]
  second = time[1]

  currentLyric = $ '.lyric.current'

  isPause = true

  playSpotify minute, second

  clearInterval window.highlightLyricsInterval

  currentLyric.addClass 'current'

playSpotify = (startMinute, startSecond) ->
  $('.lyric').removeClass 'current'

  window.currentPlayTime = (startMinute * 60 + startSecond) * 1000 unless isPause

  isPause = false

  clearInterval window.highlightLyricsInterval

  highlightLyrics = ->
    getZero = (second) ->
      aZero = '0'

      aZero = '' if currentPlayTimeSecond >= 10

      aZero

    window.currentPlayTime += 100

    currentPlayTimeMinute = parseInt(window.currentPlayTime / 1000 / 60)
    currentPlayTimeSecond = parseInt(window.currentPlayTime / 1000) - currentPlayTimeMinute * 60

    $('#track-time').text "#{currentPlayTimeMinute}:#{getZero currentPlayTimeSecond}#{currentPlayTimeSecond}"

    time = currentTrack.duration.split ':'

    minute = time[0]
    second = time[1]

    totalTrackDuration = parseInt(minute) * 60 * 1000 + parseInt(second) * 1000
    trackProgress = window.currentPlayTime / totalTrackDuration * 100

    $('#track-progress-bar').css 'background', "linear-gradient(to right, #f5110a #{trackProgress}%,#000000 #{trackProgress}%,#000000 100%)"

    for lyric in $ '.lyric'
      $lyricData = $(lyric).data()

      if (parseInt($lyricData.minute) * 60 + parseInt($lyricData.second)) * 1000 < window.currentPlayTime
        $(lyric).removeClass 'current'
      else
        $(lyric).parents('.row').prev().find('.lyric').addClass 'current'

        break

    if window.currentPlayTime > totalTrackDuration
      pause()

      window.currentPlayTime = 0

      $('#play').addClass('play').removeClass 'pause'
      $('#track-time').text '0:00'
      $('#track-progress-bar').css 'background', "linear-gradient(to right, #f5110a 0%,#000000 0%,#000000 100%)"


    if $('.lyric.current').data() && $('.lyric.current').data().annotations
      $('#annotation-text').text $('.lyric.current').data().annotations
      $('#lyric-annotation').show().fadeIn 250
    else
      $('#lyric-annotation').fadeOut 250


  window.highlightLyricsInterval = setInterval highlightLyrics, 100

  window.open "spotify:track:#{$('#spotify-track-id').val()}##{startMinute}:#{Math.round(startSecond)}", '_parent'

getLyrics = (artist, title) ->
  $.get "/lyrics/#{artist}/#{title}", (data) ->
    $('#track-player').show 'slide', { direction: 'left' }, 400
    $('#lyrics').show().html data

getSpotifyTracks = (artist, title) ->
  $.get "/tracks?artist=#{artist}&title=#{title}", (data) ->
    $('#tracks, #tracks-header').show()
    $('#tracks').html data

$ ->
  $('#track-player').css 'min-height', $(window).height()
  $('#track-lyrics, #lyric-annotation').css 'max-height', $(window).height() - 60

  $(window).on 'resize', ->
    $('#track-player').css 'min-height', $(window).height()
    $('#track-lyrics, #lyric-annotation').css 'max-height', $(window).height() - 60

  $('#play').on 'click', ->
    if $('#play').hasClass 'play'
      $('#play').addClass('pause').removeClass 'play'

      minute = parseInt(window.currentPlayTime / 1000 / 60)
      second = window.currentPlayTime / 1000 - minute * 60

      playSpotify minute, second
    else
      $('#play').addClass('play').removeClass 'pause'

      pause()

  # $(window).on 'keyup', (e) -> $('#play').trigger 'click' if e.keyCode is 32

  $('#get-lyrics').on 'click', ->
    getSpotifyTracks $('#artist').val(), $('#track').val()

  $('#tracks').on 'click', '.track', (e) ->
    $('#track-player').hide 'slide', { direction: 'right' }, 400

    if currentTrack
      $('#play').addClass('play').removeClass 'pause'

      pause()

      window.currentPlayTime = 0

    $('.track').removeClass 'current'
    $('#lyric-annotation').fadeOut 250

    currentTrack = $(@).addClass('current').data()

    $('#album-art').attr 'src', currentTrack.coverArtUrl
    $('.track-title').text currentTrack.name
    $('#track-album').text currentTrack.album
    $('#track-artist').text currentTrack.artist
    $('#spotify-track-id').val currentTrack.id
    $('#track-time').text '0:00'
    $('#track-duration').text currentTrack.duration.substr(1)
    $('#track-progress-bar').css 'background', "linear-gradient(to right, #f5110a 0%,#000000 0%,#000000 100%)"

    getLyrics currentTrack.artist, currentTrack.name

  $('#lyrics').on 'click', '.lyric', (e) ->
    if $(@).hasClass 'current'
      $('#play').trigger 'click'
    else
      window.currentPlayTime = parseInt($(@).data().minute) * 60 * 1000 + parseInt($(@).data().second) * 1000

      $('#play').addClass('play').removeClass('pause').trigger 'click'

  $('#track-progress-bar').on 'click', (e) ->
    time = currentTrack.duration.split ':'

    minute = time[0]
    second = time[1]

    totalTrackDuration = parseInt(minute) * 60 * 1000 + parseInt(second) * 1000

    window.currentPlayTime = parseInt(e.pageX - $(@).offset().left) / parseInt($(@).width()) * totalTrackDuration

    $('#play').addClass('play').removeClass('pause').trigger 'click'
