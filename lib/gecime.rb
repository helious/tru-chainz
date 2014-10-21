class Gecime
  attr_reader :artist, :title

  def initialize artist, title
    @artist = artist
    @title = title
  end

  def retrieve_lrc
    unless songs_response['count'] == 0
      gecime_lrc_response if gecime_lrc_response
    end
  end

  private

  def songs_response
    @songs_responses ||= JSON.parse gecime_songs_response
  end

  def gecime_songs_response
    HTTParty.get("http://geci.me/api/lyric/#{ uri_safe title }/#{ uri_safe artist }?json=true").body
  rescue
    nil
  end

  def uri_safe param
    param.to_query('')[1..-1].gsub '+', '%20'
  end

  def gecime_lrc_response
    @gecime_lrc_response ||= HTTParty.get(songs_response['result'][0]['lrc']).body
  rescue
    nil
  end

end
