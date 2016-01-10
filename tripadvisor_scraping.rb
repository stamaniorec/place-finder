require 'mechanize'
require 'sanitize'

class TripAdvisorScraping
  def initialize
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def get_search_url(place_name)
    "http://www.tripadvisor.com/Search?q=#{place_name}"
  end

  def found_place?(page, target)
    page.search('.title').any? do |place_name|
      Sanitize.clean(place_name.child.inner_html) == target
    end
  end

  def navigate_to_hotel_page(suggestions_page, place_name)
    a = suggestions_page.search('.title')[1]
    b = a['onclick'].match(/\/[\w-]+.html/).to_s
    c = 'http://www.tripadvisor.com/' + b
    @browser.get(c)
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

  def get_rating_value(hotel_page)
    hotel_page.at('img[property=\'ratingValue\']').attribute('alt').inner_html rescue nil
  end

  def get_data(place_name)
    hotel_page = get_hotel_page(place_name)

    {}.tap do |data|
      if hotel_page == :not_found
        data[:status] = :not_found
      else
        data[:status] = :ok
        data[:rating_value] = get_rating_value(hotel_page)
      end
    end
  end
end

a = TripAdvisorScraping.new
p a.get_data('Pine Bay Holiday Resort')