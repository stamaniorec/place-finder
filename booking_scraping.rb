require 'mechanize'

class BookingScraping
  def initialize
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def found_place?(page, target)
    page.search('.destination_name').any? do |place_name|
      place_name.inner_html == target
    end
  end

  def get_search_url(place_name)
    "http://www.booking.com/search.bg.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=#{place_name}/"
  end

  def get_suggestions_page(place_name)
    url = get_search_url(place_name)
    @browser.get(url) do |suggestions_page|
      suggestions_page
    end
  end

  def navigate_to_hotel_page(suggestions_page, place_name)
    link_to_hotel_list = suggestions_page.link_with(text: place_name)
    hotel_list = link_to_hotel_list.click

    target_place_link = hotel_list.link_with(text: "\n#{place_name}\n")
    target_place_link.click
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
    if hotel_page == :not_found
      return "not found :("
    else
      hotel_page.at('#hp_hotel_name').inner_html
      # ...
    end
    # fill data hash
    # return data
  end
end

a = BookingScraping.new
p a.get_data('Ephesia Holiday Beach Club')