class BaseScraper
  def initialize
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def get_suggestions_page(place_name)
    url = get_search_url(place_name)
    @browser.get(url)
  end

  def get_hotel_page(place_name)
    suggestions_page = get_suggestions_page(place_name)

    if found_place?(suggestions_page, place_name)
      navigate_to_hotel_page(suggestions_page, place_name)
    else
      :not_found
    end
  end

  def get_data(place_name)
    hotel_page = get_hotel_page(place_name)

    {}.tap do |data|
      if hotel_page == :not_found
        data[:status] = :not_found
      else
        data[:status] = :ok
        build_data(hotel_page, data)
      end
    end
  end
end