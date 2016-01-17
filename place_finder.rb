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
  @query = params[:search]
  @suggestions = get_suggestions(@query)
  erb :results
end

get '/place/:name/:place_id' do
  @name = params[:name]
  @data = build_data(@name, params[:place_id])
  erb :place
end

get '/get_photo/:photo_reference' do
  GooglePlaces::PlacePhoto::place_photo(params[:photo_reference])
end