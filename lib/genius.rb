require 'rapgenius'

class Genius
  class << self

    def track_id artist, title
      RapGenius.search_by_title(title).each do |song|
        return song.id if song.artist.name.downcase == artist
      end
    rescue
      nil
    end

    def retrieve_track id
      RapGenius::Song.find id
    rescue
      nil
    end

  end
end