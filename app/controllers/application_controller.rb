require 'lyric_query'
require 'spotify'

class ApplicationController < ActionController::Base
  Lyric = Struct.new :text, :start_minute, :start_second, :annotations

  protect_from_forgery with: :exception

  def root; end

  def track
    spotify = GetSpotify.new

    @tracks = spotify.getSpotify params[:artist], params[:track]

    render layout: false
  end

  def lyrics
    @lyrics = []

    begin
      LyricQuery.new.query_song(params[:artist], params[:track]).each do |lyric|
        begin
          time = lyric[0].split ':'

          start_minute = time.first
          start_second = time.last

          unless %w(ti ar al by).include? start_minute
            @lyrics.push Lyric.new lyric[1].lyric.force_encoding('UTF-8'), start_minute, start_second, lyric[1].annotations if start_second.to_f > 0
          end
        rescue
          nil
        end
      end
    rescue
      nil
    end

    render layout: false
  end

end
