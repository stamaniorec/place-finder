require 'net/http'
require 'json'

module GooglePlaces
  KEY = 'AIzaSyBSRWdglaKrdSpIz14qipycfAR0WqwXEQs'

  def self.request(url)
    response = Net::HTTP.get(URI.parse(url))
    json_response = JSON.parse(response)

    if json_response['status'] == 'OK'
      yield json_response
    else
      json_response
    end
  end

  module TextSearch
    ENDPOINT = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'

    class << self
      def url(query)
        "#{ENDPOINT}query=#{query}&key=#{KEY}"
      end

      def text_search(query)
        GooglePlaces::request(url(query)) do |response|
          response['results']
        end
      end
    end    
  end

  module PlaceDetails
    ENDPOINT = 'https://maps.googleapis.com/maps/api/place/details/json?'

    def self.url(place_id)
      "#{ENDPOINT}placeid=#{place_id}&key=#{KEY}"
    end

    def self.place_details(place_id)
      GooglePlaces::request(url(place_id)) do |response|
        response['result']
      end
    end
  end

  module PlacePhoto
    ENDPOINT = 'https://maps.googleapis.com/maps/api/place/photo?'

    def self.url(photo_reference)
      "#{ENDPOINT}max_width=800&photoreference=#{photo_reference}&key=#{KEY}"
    end

    def self.place_photo(photo_reference)
      Net::HTTP.get(URI.parse(url(photo_reference)))
    end
  end
end