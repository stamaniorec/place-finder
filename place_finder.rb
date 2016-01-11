require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'booking_scraping'
require_relative 'google_places'

helpers do
  def get_suggestions(query)
    GooglePlaces::TextSearch::text_search(query)
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
  google_places_result = GooglePlaces::TextSearch::text_search(@name)
  @rating = google_places_result.first['rating']
  @booking_data = BookingScraping.new.get_data(@name)
  erb :place
end
