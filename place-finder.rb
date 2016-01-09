require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  erb :index
end

require 'net/http'
require 'json'

post '/' do
  @query = params[:search]
  key = 'AIzaSyARbPKh6w-tSaeNGX3wpvY_EQoHDIzYgh0'
  endpoint = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
  url = endpoint + "query=#{@query}&key=#{key}"
  response = Net::HTTP.get(URI.parse(url))
  json_response = JSON.parse(response)
  status = json_response['status']
  if status != 'OK'
    p 'whoops something went wrong'
    erb :error
  else
    @suggestions = json_response['results']
    erb :results
  end
end

