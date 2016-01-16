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

get '/place/:name' do
  @name = params[:name]
  @data = build_data(@name)
  erb :place
end

require 'json'

get '/get_data/booking/:name' do
  BookingScraping.new.get_data(params[:name]).to_json
end