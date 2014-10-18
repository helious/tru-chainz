require 'json'
require 'httparty'

class LyricQuery
   attr_accessor :artist, :song, :lrc_link, :lyrics, :found

   def initialize
      #instance variables
      @song = nil
      @artist = nil
      @lrc_link = nil
      @lyrics = nil
      @found = false
   end

   #query_song returns -1 if it cannot find a song, else it returns the lyrics
   def query_song artist_query, song_query
      artist = artist_query
      song = song_query

      results = nil

      json_query = HTTParty.get(URI.encode("http://geci.me/api/lyric/#{song_query}/#{artist_query}?json=true"))
      json_query = json_query.body

      json_hash = JSON.parse(json_query)

      if json_hash["count"] == 0
         return -1
      else
         results = json_hash["result"]
         #Just get the first element of the array
         res = results[0]
         lrc_link = res["lrc"]

         lyrics = HTTParty.get(lrc_link)
         lyrics = lyrics.body
         return lyrics
      end
   end

end