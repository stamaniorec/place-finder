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

  def build_data(name, place_id)
    google_places = GooglePlaces::PlaceDetails.place_details(place_id)#get_google_places_data(name)
    # if out of quota, private method `select' called for nil:NilClass
    locality = google_places['address_components'].select { |component| component['types'].include?('locality') }.first
    locality = locality ? locality['long_name'] : ''
    p '!!!!!!!!!!'
    p "query is #{locality}"
    p "class is #{locality.class}"
    query = "#{name} #{locality}"
    booking = BookingScraping.new.get_data(name, locality)
    tripadvisor = TripAdvisorScraping.new.get_data(name, locality)

    google_places.merge(booking).merge(tripadvisor)
  end
end