SpotifyTrack = Struct.new :spotify_id, :duration, :artist, :name, :cover_art_url, :album

class GetSpotify

	def getSpotify artist_query, song_query
		query = case
    when artist_query.blank? && song_query.blank?
  		'year:2005'
  	when artist_query.blank?
   		"track:#{song_query}"
  	when song_query.blank?
   		"artist:#{artist_query}"
  	else
			"track:#{song_query}+artist:#{artist_query}"
  	end
	  
	  json_query = HTTParty.get(URI.encode("https://api.spotify.com/v1/search?q=#{query}&limit=5&type=track"))

	  json_hash = JSON.parse json_query.body
	  
	  arr = []
	  
	  unless json_hash["count"] == 0
			json_hash["tracks"]["items"].each do |item|
				image = item["album"]["images"][0]["url"]
				album = item["album"]["name"]
				uri = item["id"]
				duration = item["duration_ms"]
				seconds = duration/1000
				duration = Time.at(seconds).strftime("%M:%S")
				track = item["name"]
				artist = item["artists"][0]["name"]
				 
				arr.push SpotifyTrack.new(uri, duration, artist, track, image, album) 
		  end
		end

	  arr
	end

end
