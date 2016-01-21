require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for2'
require 'unidecoder'

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

get '/place/:place_id' do
  @data = build_data(params[:place_id])
  erb :place
end

get '/get_photo/:photo_reference' do
  GooglePlaces::PlacePhoto::place_photo(params[:photo_reference])
end