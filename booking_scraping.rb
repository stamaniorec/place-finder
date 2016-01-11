require 'mechanize'

require_relative 'base_scraper'

class BookingScraping < BaseScraper
  def found_place?(page, target)
    page.search('.destination_name').any? do |place_name|
      place_name.inner_html == target
    end
  end

  def get_search_url(place_name)
    "http://www.booking.com/search.bg.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=#{place_name}/"
  end

  def navigate_to_hotel_page(suggestions_page, place_name)
    link_to_hotel_list = suggestions_page.link_with(text: place_name)
    hotel_list = link_to_hotel_list.click

    target_place_link = hotel_list.link_with(text: "\n#{place_name}\n")
    target_place_link.click
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
    data.tap do |data|
      data[:stars] = get_stars(hotel_page)
      data[:location_perk] = get_location(hotel_page)
      data[:booking_score_word] = get_score_word(hotel_page)
      data[:booking_rating_score] = get_score_value(hotel_page)
      data[:booking_link] = get_link_to(hotel_page)
    end
  end
end

a = BookingScraping.new
p a.get_data('Новотел София')