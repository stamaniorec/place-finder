require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'booking_scraping'
require_relative 'google_places'
require_relative 'tripadvisor_scraping'

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

get '/' do
  erb :index
end

post '/' do
  @suggestions = get_suggestions(params[:search])
  erb :results
end

get '/place/:name' do
  @name = params[:name]
  
  @booking_data = BookingScraping.new.get_data(@name)
  @tripadvisor_data = TripAdvisorScraping.new.get_data(@name)
  @google_places_data = GooglePlaces::PlaceDetails.place_details(get_google_place_id(@name))

  @data = build_data(@name)

  erb :place
end
