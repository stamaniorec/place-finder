helpers do
  def get_suggestions(query)
    GooglePlaces::TextSearch::text_search(query)
  end

  def successful?(response)
    response.is_a? Array
  end

  def get_locality_component(address_components)
    address_components.select { |comp| comp['types'].include?('locality') }.first
  end

  def get_locality(google_places_data)
    locality_component = get_locality_component(google_places_data['address_components'])
    locality_component ? locality_component['long_name'] : ''
  end

  def build_data(place_id)
    google_places = GooglePlaces::PlaceDetails.place_details(place_id)

    if google_places.has_key?('status') and google_places['status'] != 'OK'
      return google_places
    end

    p 'getting locality'
    p "#{get_locality(google_places)}"
    p google_places
    query = "#{google_places['name']} #{get_locality(google_places)}"

    booking = BookingScraping.new.get_data(query)
    tripadvisor = TripAdvisorScraping.new.get_data(query)

    google_places.merge(booking).merge(tripadvisor)
  end
end