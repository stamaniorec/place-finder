module Helpers
  def create_user(params)
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)

    User.new(
      email: params[:email],
      password_hash: password_hash,
      password_salt: password_salt
    )
  end

  def authenticate(user, password)
    user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
  end

  def login(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def get_suggestions(query)
    GooglePlaces::TextSearch::text_search(URI.encode(query))
  end

  def successful?(response)
    response.is_a? Array
  end

  def get_locality_component(address_components)
    address_components.select { |comp| comp['types'].include?('locality') }.first
  end

  def get_locality(google_places_data)
    locality_component = get_locality_component(google_places_data['address_components'])
    locality_component ? locality_component['long_name'] : ''
  end

  def platforms
    [
      BookingScraping,
      TripAdvisorScraping,
    ]
  end

  def build_data(place_id)
    google_places = GooglePlaces::PlaceDetails.place_details(place_id)

    if google_places.has_key?('status') and google_places['status'] != 'OK'
      return google_places
    end

    platforms.each_with_object(google_places) do |platform, data|
      data.merge!(platform.new.get_data(data))
    end
  end
end