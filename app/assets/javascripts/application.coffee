//= require jquery
//= require jquery_ujs
//= require_tree .

window.currentPlayTime = 0
window.highlightLyricsInterval = null

pause = ->
  window.currentPlayTime = 0

  playSpotify 3, 58

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
  $.get "/lyrics/#{artist}/#{track}", (data) -> $('#lyrics').html data

getSpotifyId = (artist, track) ->
  $.get "/track/#{artist}/#{track}", (data) -> $('#spotify-track-id').val data.spotify_track_id

$ ->
  $('#play').on 'click', -> playSpotify 0, 0
  $('#pause').on 'click', pause

  $('#get-lyrics').on 'click', ->
    getLyrics $('#artist').val(), $('#track').val()
    getSpotifyId $('#artist').val(), $('#track').val()

  $('#lyrics').on 'click', '.lyric', (e) ->
    e.preventDefault()

    $(@).addClass 'current'

    playSpotify $(@).data().minute, $(@).data().second

  getLyrics 'taylor swift', 'tim mcgraw'
  getSpotifyId 'taylor swift', 'tim mcgraw'
