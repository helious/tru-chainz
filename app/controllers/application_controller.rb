require 'lyrics'
require 'spotify'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def root; end

  def tracks
    spotify = GetSpotify.new

    @tracks = spotify.getSpotify params[:artist], params[:title]

    render layout: false
  end

  def lyrics
    @lyrics = Lyrics.new(params[:artist], params[:title]).retrieve

    render layout: false
  end

end
