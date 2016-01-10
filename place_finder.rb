require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'booking_scraping'
require_relative 'google_places_text_search'

helpers do
  def get_suggestions(query)
    GooglePlacesTextSearch.text_search(params[:search])
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
  google_places_result = GooglePlacesTextSearch.text_search(@name)
  # p google_places_result
  @rating = google_places_result.first['rating']
  @booking_data = BookingScraping.new.get_data(@name)
  erb :place
end

