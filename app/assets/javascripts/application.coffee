//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

window.currentPlayTime = 0
window.highlightLyricsInterval = null

currentSongData = null

pause = ->
  window.currentPlayTime = 0

  time = currentSongData.duration.split ':'

  minute = time[0]
  second = time[1] 

  playSpotify minute, second

  clearInterval window.highlightLyricsInterval

playSpotify = (startMinute, startSecond) ->
  $('.lyric').removeClass 'current'

  window.currentPlayTime = (startMinute * 60 + startSecond) * 1000

  clearInterval window.highlightLyricsInterval

  highlightLyrics = ->
    window.currentPlayTime += 100

    for lyric in $ '.lyric'
      $lyricData = $(lyric).data()

      if ($lyricData.minute * 60 + $lyricData.second) * 1000 < window.currentPlayTime
        $(lyric).removeClass 'current'
      else
        $(lyric).parents('.row').prev().find('.lyric').addClass 'current'

        break


  window.highlightLyricsInterval = setInterval highlightLyrics, 100

  window.open "spotify:track:#{$('#spotify-track-id').val()}##{startMinute}:#{startSecond}", '_parent'

getLyrics = (artist, track) ->
  $.get "/lyrics/#{artist}/#{track}", (data) ->
    $('#track-player').show 'slide', { direction: 'left' }, 400
    $('#lyrics').show().html data

getSpotifyTracks = (artist, track) ->
  $.get "/track?artist=#{artist}&track=#{track}", (data) -> $('#tracks').show().html data

$ ->
  $('#track-player').css 'min-height', $(window).height()

  $('#play').on 'click', ->
    if $('#play').hasClass 'play'
      $(@).addClass('pause').removeClass 'play'

      playSpotify 0, 0
    else
      $('#play').addClass('play').removeClass 'pause'

      pause()

  $('#get-lyrics').on 'click', ->
    getSpotifyTracks $('#artist').val(), $('#track').val()

  $('#tracks').on 'click', '.track', (e) ->
    $('#track-player').hide 'slide', { direction: 'right' }, 400

    if currentSongData
      $('#play').addClass('play').removeClass 'pause'

      pause()

    $('.track').removeClass 'current'

    currentSongData = $(@).addClass('current').data()

    $('#album-art').attr 'src', currentSongData.coverArtUrl
    $('#track-title').text currentSongData.name
    $('#track-artist').text currentSongData.artist
    $('#spotify-track-id').val currentSongData.id

    getLyrics currentSongData.artist, currentSongData.name

  $('#lyrics').on 'click', '.lyric', (e) ->
    e.preventDefault()

    $('#play').addClass('pause').removeClass 'play'

    playSpotify $(@).data().minute, $(@).data().second
