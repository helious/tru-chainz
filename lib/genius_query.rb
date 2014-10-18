require 'rapgenius'

class GeniusQuery
    def initialize
    end

    #Return Genius ID of song, if not found, return -1
    def get_genius_result_id artist, song
        rap_query_array = RapGenius.search_by_title(song)

        #Find matching artist
        id = -1
        rap_query_array.each do | entry |
            if entry.artist.name.casecmp(artist) == 0
                id = entry.id
                break
            end
        end
        return id
    end

    #Get the song object, which contains lines and annotations
    def get_genius_song id
        song = RapGenius::Song.find(id)
    end

end