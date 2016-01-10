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
    @browser.get(url)
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

  def get_stars(hotel_page)
    hotel_page.at('.star_track')['title'].split.first.to_i rescue nil
  end

  def get_location(hotel_page)
    hotel_page.at('.facility-badge__title').inner_html.split("\n").last rescue nil
  end

  def get_score_word(hotel_page)
    hotel_page.at('.js--hp-scorecard-scoreword').inner_html rescue nil
  end

  def get_score_value(hotel_page)
    hotel_page.at('.js--hp-scorecard-scoreval').inner_html.to_f rescue nil
  end

  def get_link_to(hotel_page)
    hotel_page.uri.to_s
  end

  def build_data(hotel_page, data)
    data[:stars] = get_stars(hotel_page)
    data[:location] = get_location(hotel_page)
    data[:score_word] = get_score_word(hotel_page)
    data[:rating_score] = get_score_value(hotel_page)
    data[:link_to_booking] = get_link_to(hotel_page)
    data
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

a = BookingScraping.new
p a.get_data('Новотел София')