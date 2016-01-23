require 'sinatra'
require 'sinatra/flash'
require 'sinatra/reloader' if development?
require 'sinatra/content_for2'
require 'unidecoder'
require 'bcrypt'

require 'sinatra/activerecord'

configure :development do
  set :database, {adapter: 'sqlite3', database: 'db.sqlite3'}
end

configure :production do
  set :database, {adapter: 'postgresql', database: ENV['DATABASE_URL'], host: 'localhost', encoding: 'unicode', pool: 5, port: 5432}
end

require_relative 'models/user'

require_relative 'apis/google_places'
require_relative 'scrapers/booking_scraping'
require_relative 'scrapers/tripadvisor_scraping'

require_relative 'helpers'
include Helpers

enable :sessions

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

require_relative 'routes/auth'