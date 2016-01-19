require 'mechanize'

require_relative 'base_scraper'

class BookingScraping < BaseScraper
  def found_place?(page, target)
    page.search('.destination_name').any? do |place_name|
      similar_enough?(place_name.inner_html, target)
    end
  end

  def get_search_url(place_name)
    "http://www.booking.com/search.bg.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=#{place_name}/"
  end

  def navigate_to_hotel_page(suggestions_page, query)
    hotel_list = @browser.click(suggestions_page.at('.destination_name'))
    @browser.click(hotel_list.at('.hotel_name_link'))
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

  def set_error(data)
    data.tap { |data| data[:booking_status] = :not_found }
  end

  def set_success(data)
    data.tap { |data| data[:booking_status] = :ok }
  end

  def build_data(hotel_page, data)
    data.tap do |data|
      data[:stars] = get_stars(hotel_page)
      data[:location_perk] = get_location(hotel_page)
      data[:booking_score_word] = get_score_word(hotel_page)
      data[:booking_rating_score] = get_score_value(hotel_page)
      data[:booking_link] = get_link_to(hotel_page)
    end
  end
end