require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'google_places_text_search'

get '/' do
  erb :index
end

post '/' do
  @suggestions = GooglePlacesTextSearch.text_search(params[:search])
  erb :results
end