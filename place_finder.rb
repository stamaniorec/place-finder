require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'apis/google_places'
require_relative 'scrapers/booking_scraping'
require_relative 'scrapers/tripadvisor_scraping'

require_relative 'helpers'

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