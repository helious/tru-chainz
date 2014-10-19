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
		 while i < (genius_song.lines.length - 1)
			#puts genius_song.lines.length
			#puts "i is #{i} of #{genius_song.lines.length}"
			
			#puts genius_song.lines[i].annotations
			if genius_song.lines[i].lyric.include? '[' || genius_song.lines[i].lyric == nil
				i+=1
			end
			j = 0;
			while j < (lyric_hash.length - 1)
				#puts "hash length is #{lyric_hash.length}"
				#puts "i is #{i}"
				#puts "j is #{j}"
				
				while lyric_hash[lyric_hash.keys[j]].lyric == nil || lyric_hash[lyric_hash.keys[j]].lyric == ""
					j+=1
					
				end
				#binding.pry
				jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
			
			
				gline = genius_song.lines[i].lyric.downcase.gsub(/[^0-9A-Za-z]/, '').gsub("quot","")
				lline = lyric_hash[lyric_hash.keys[j]].lyric.downcase.gsub(/[^0-9A-Za-z]/, '').gsub("quot","")
				
				#if(lline != nil)
				
					
				   #puts " Genius: #{gline}"
				   #puts " Ghetto: #{lline}"
				
					perct = jarow.getDistance(gline, lline) 
					#puts "percentage is #{perct}"
					if perct > 0.70 
						lyric_hash[lyric_hash.keys[j]].annotations = genius_song.lines[i].annotations
					
					elsif gline.include?(lline)
						#binding.pry
						#puts "in"
						lyric_hash[lyric_hash.keys[j]].annotations = genius_song.lines[i].annotations
				
					#else puts "do nothing"
						#lyric_hash[lyric_hash.keys[j]].annotations = lyric_hash[lyric_hash.keys[j-1]].annotations
					
					end
				#end
				j+=1
			end
			i+=1
		end

      end 
	  return lyric_hash
   end

end