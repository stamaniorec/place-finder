helpers do
  def get_suggestions(query)
    GooglePlaces::TextSearch::text_search(query)
  end

  def get_google_place_id(place_name)
    GooglePlaces::TextSearch::text_search(place_name).first['place_id']
  end

  def build_data(name)
    google_places = GooglePlaces::PlaceDetails.place_details(get_google_place_id(name))
    booking = BookingScraping.new.get_data(name)
    tripadvisor = TripAdvisorScraping.new.get_data(name)

    google_places.merge(booking).merge(tripadvisor)
  end
end