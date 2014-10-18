require 'lyric_query'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def root
    lyric_queryer = LyricQuery.new

    @lyrics = lyric_queryer.query_song 'Taylor Swift', 'Tim McGraw'
  end

end
