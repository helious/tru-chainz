require 'json'
require 'httparty'
require 'rails'
#require 'pry'

class SpotifyTrack < Struct.new(:spotify_id, :duration, :artist, :name, :cover_art_url, :album) 
end

class GetSpotify
#query_song returns -1 if it cannot find a song, else it returns the lyrics
	def getSpotify artist_query, song_query
		
	  if artist_query.blank? && song_query.blank?
		json_query = HTTParty.get(URI.encode("https://api.spotify.com/v1/search?q=year:2005&limit=5&type=track"))
	  elsif artist_query.blank?
	   json_query = HTTParty.get(URI.encode("https://api.spotify.com/v1/search?q=track:#{song_query}&limit=5&type=track"))
	  elsif song_query.blank?
	   json_query = HTTParty.get(URI.encode("https://api.spotify.com/v1/search?q=artist:#{artist_query}&limit=5&type=track"))
	  else
		json_query = HTTParty.get(URI.encode("https://api.spotify.com/v1/search?q=track:#{song_query}+artist:#{artist_query}&limit=5&type=track"))
	  end
	  
	  #json_query = HTTParty.get(URI.encode("http://geci.me/api/lyric/#{song_query}/#{artist_query}?json=true"))
	  #puts json_query
	  json_query = json_query.body
	  json_hash = JSON.parse(json_query)
	  
	  #puts json_hash
	  #binding.pry
	  #puts json_hash["count"]
	  #albumart, spotifyuri, track, artist
	  
	  if json_hash["count"] == 0
		 return -1
	  else
		
		arr = Array.new()
		
		json_hash["tracks"]["items"].each do |item|
			
			image = item["album"]["images"][0]["url"]
			album = item["album"]["name"]
			uri = item["id"]
			duration = item["duration_ms"]
			seconds = duration/1000
			duration = Time.at(seconds).strftime("%M:%S")
			track = item["name"]
			artist = item["artists"][0]["name"]
			 
			# image = json_hash["tracks"]["items"][0]["album"]["images"][0]["url"]
			 #uri = json_hash["tracks"]["items"][0]["id"]
			 #track = json_hash["tracks"]["items"][0]["name"]
			 #artist = json_hash["tracks"]["items"][0]["artists"][0]["name"]
			
			 arr.push(SpotifyTrack.new(uri, duration, artist, track, image, album))
			 #puts image
			 #puts uri 
			 #puts duration
			 #puts track 
			 #puts artist
			 
			 #Just get the first element of the array
			 #puts results

			 #lyrics = HTTParty.get(lrc_link)
			 #lyrics = lyrics.body
			 #return parse_lyrics_to_hash(lyrics)
		 end
		 
	  end
	  
	  return arr
	  
	end

end