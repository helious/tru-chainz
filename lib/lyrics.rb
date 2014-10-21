require 'gecime'
require 'genius'
require 'fuzzystringmatch'

Lyric = Struct.new :text, :start_minute, :start_second, :annotations

class Lyrics
  attr_reader :artist, :title, :lyrics, :found

  def initialize artist, title
    @lyrics = []
    @artist = artist.strip.split.join(' ').downcase
    @title = title.split('-')[0].split('(')[0].strip.split.join(' ').downcase
  end

  def retrieve
    Rails.cache.fetch "#{artist}:#{title}:annotated" do
      convert_lrc_file_to_lyrics! if lrc_file

      add_genius_annotations!

      lyrics
    end
  end

  private

  def lrc_file
    @lrc_file ||= Gecime.new(artist, title).retrieve_lrc
  end

  def convert_lrc_file_to_lyrics!
    time_keyed_lyric_hash = {}

    lrc_file.split("\n").each do |line|
      line_array = line.force_encoding('UTF-8').split ']'
      lyric_text = line_array.last

      if lyric_text.present?
        line_array.each do |item|
          unless item == lyric_text
            lyric_object = Lyric.new

            time = item.sub('[', '').split ':'

            start_minute = time.first
            start_second = time.last

            unless %w(ti ar al by).include?(start_minute) || start_second.to_f < 0
              text = CGI.unescapeHTML lyric_text

              begin
                time_in_seconds = start_minute.to_i * 60 + start_second.to_f

                time_keyed_lyric_hash[time_in_seconds] = Lyric.new text, start_minute, start_second, nil
              rescue
              end
            end
          end
        end
      end
    end

    Hash[time_keyed_lyric_hash.sort].each do |_, lyric|
      @lyrics.push lyric
    end
  end

  def add_genius_annotations!
    if genius_track_id
      used_annotations = {}

      genius_track.lines.each do |genius_line|
        next if genius_line.lyric == nil || genius_line.lyric.include?('[')

        genius_lyric_text = sanitize genius_line.lyric

        lyrics.each do |lyric|
          lyric_text = sanitize lyric.text

          if lyrics_match?(genius_lyric_text, lyric_text) && lyric.annotations.nil?
            unless used_annotations["#{lyric_text}:#{genius_line.annotations}"]
              lyric.annotations = genius_line.annotations

              used_annotations["#{lyric_text}:#{genius_line.annotations}"] = true

              next
            end
          end
        end
      end if genius_track
    end
  end

  def genius_track_id
    @genius_track_id ||= Genius.track_id artist, title
  end

  def genius_track
    @genius_track ||= Genius.retrieve_track genius_track_id 
  end

  def sanitize string
    string.downcase.gsub /[^0-9a-z]/, ''
  end

  def lyrics_match? genius_lyric_text, lyric_text
    fuzzy_string_matcher.getDistance(genius_lyric_text, lyric_text) > 0.795 || genius_lyric_text.include?(lyric_text)
  end

  def fuzzy_string_matcher
    @fuzzy_string_matcher ||= FuzzyStringMatch::JaroWinkler.create :pure
  end

end