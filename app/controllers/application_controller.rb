require 'lyric_query'
require 'spotify'

class ApplicationController < ActionController::Base
  Lyric = Struct.new :text, :start_minute, :start_second

  protect_from_forgery with: :exception

  def root; end

  def track
    spotify = GetSpotify.new

    @tracks = spotify.getSpotify params[:artist], params[:track]

    render layout: false
  end

  def lyrics
    @lyrics = []

    LyricQuery.new.query_song(params[:artist], params[:track]).each do |k, v|
      begin
        time = k.split ':'

        start_minute = time.first
        start_second = time.last

        unless %w(ti ar al by).include? start_minute
          @lyrics.push Lyric.new v, start_minute, start_second if start_second.to_f > 0
        end
      rescue
        nil
      end
    end

    render layout: false
  end

end
