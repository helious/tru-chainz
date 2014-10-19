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
         return add_genius_annotations_new(lyric_hash, artist, song)
      end
   end

   def parse_lyrics_to_hash lyrics
      lyric_hash = Hash.new
      lyric_array = lyrics.split("\n")
      lyric_array.each do | lyric | 
         lyric_object = Lyric.new
         
         edited_lyric = lyric.sub('[','')
         edited_lyric = edited_lyric.split(']')
         lyric_object.lyric = edited_lyric[1]

         lyric_hash[edited_lyric[0]] = lyric_object  
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



   #This just spreads out annotations, doesn't align them up correctly but it gets the job done
   def add_genius_annotations_new lyric_hash, artist, song
      a = GeniusQuery.new
      genius_song_id = a.get_genius_result_id(artist, song)

      if (genius_song_id == -1)
         return lyric_hash
      end

      genius_song = a.get_genius_song(genius_song_id)
      
      #genius_song.lines[i].lyric
      #lyric_hash[lyric_hash.keys[j]].lyric
      
      #Find a valid j index to start with
      j = 0
      while true
         key = lyric_hash.keys[j]
         key = key.split(":")
         if key[0] == "00"
            if key[1].to_i >= 0
               break
            end
         end
         j+=1
      end


      lyric_hash_length = lyric_hash.length - j
      genius_song_length = genius_song.lines.length 


      ratio = genius_song_length.to_f/lyric_hash_length
      i = 0
      while true
         j = (i*ratio).floor
         if j >= lyric_hash_length || i >= genius_song_length
            break 
         end
         lyric_hash[lyric_hash.keys[j]].annotations = genius_song.lines[i].annotations
         i+=1
         j=0
      end
     
     return lyric_hash
   end
end