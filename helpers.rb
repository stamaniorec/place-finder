helpers do
  def get_suggestions(query)
    GooglePlaces::TextSearch::text_search(query)
  end

  def successful?(response)
    response.is_a? Array
  end

  def get_google_places_data(name)
    response = GooglePlaces::TextSearch::text_search(name)
    google_place_id = successful?(response) ? response.first['place_id'] : nil
    google_places = GooglePlaces::PlaceDetails.place_details(google_place_id)
  end

  def build_data(name)
    google_places = get_google_places_data(name)
    booking = BookingScraping.new.get_data(name)
    tripadvisor = TripAdvisorScraping.new.get_data(name)

    google_places.merge(booking).merge(tripadvisor)
  end
end