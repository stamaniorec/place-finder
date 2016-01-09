require 'net/http'
require 'json'

class GooglePlacesTextSearch
  KEY = 'AIzaSyBSRWdglaKrdSpIz14qipycfAR0WqwXEQs'
  ENDPOINT = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'

  def self.get_url(query)
    "#{ENDPOINT}query=#{query}&key=#{KEY}"
  end

  def self.text_search(query)
    url = self.get_url(query)
    response = Net::HTTP.get(URI.parse(url))
    json_response = JSON.parse(response)

    if json_response['status'] == 'OK'
      json_response['results']
    else
      :error
    end
  end
end