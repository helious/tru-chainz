require 'json'
require 'httparty'
require_relative 'lyric'
require_relative 'genius_query'
require 'fuzzystringmatch'

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

      json_query = HTTParty.get("http://geci.me/api/lyric/#{ URI.encode song_query }/#{ URI.encode artist_query }?json=true")
      json_query = json_query.body

      json_hash = JSON.parse(json_query)

      unless json_hash["count"] == 0
         results = json_hash["result"]
         #Just get the first element of the array
         res = results[0]
         lrc_link = res["lrc"]

         lyrics = HTTParty.get(lrc_link)
         lyrics = lyrics.body
         lyric_hash = parse_lyrics_to_hash(lyrics)
       #return lyric_hash
         return add_genius_annotations(lyric_hash, artist, song)
      end
   end

   def parse_lyrics_to_hash lyrics
      lyric_hash = Hash.new

      lyric_array = lyrics.split("\n")

      lyric_array.each do | lyric | 
        lyric_split = lyric.split(']')

        if lyric_split.last.present?
          lyric_split.each do |time|
            if time != lyric_split.last
              lyric_object = Lyric.new

              lyric_key = time.sub '[',''
              lyric_object.lyric = lyric_split.last

              lyric_hash[lyric_key] = lyric_object
            end
          end
        end
      end

      return lyric_hash
   end

   def add_genius_annotations lyric_hash, artist, song
     a = GeniusQuery.new
      genius_song_id = a.get_genius_result_id(artist,song)
      
     if (genius_song_id == -1) 
         return lyric_hash
      else 
         
       genius_song = a.get_genius_song(genius_song_id)
       
       i=0
       j=0
       while i < genius_song.lines.length
         #puts genius_song.lines[i].annotations
         if genius_song.lines[i].lyric.include? '['
            i+=1
         end
         
         while j < lyric_hash.length
            jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
            
            if(lyric_hash[lyric_hash.keys[j]].lyric != nil && genius_song.lines[i].present?)
               perct = jarow.getDistance(genius_song.lines[i].lyric, lyric_hash[lyric_hash.keys[j]].lyric)

               if perct > 0.5
                  lyric_hash[lyric_hash.keys[j]].annotations = genius_song.lines[i].annotations
                  #puts genius_song.lines[i].annotations
                  i+=1
               elsif j > 1
                  
                  #lyric_hash[lyric_hash.keys[j]].annotations = lyric_hash[lyric_hash.keys[j-1]].annotations
               
               end
            end
            j+=1
         end
         i+=1
      end

      end 
     return lyric_hash
   end

end