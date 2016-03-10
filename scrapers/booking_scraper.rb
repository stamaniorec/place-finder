require 'mechanize'

require_relative 'base_scraper'

class BookingScraping < BaseScraper
  def get_search_url(query)
    "http://www.booking.com/search.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=#{query}/"
  end

  def navigate_from_suggestions_page_to_hotel_page(suggestions_page, query)
    hotel_list = get_hotel_list(suggestions_page, query)

    if hotel_list
      navigate_from_hotel_list_to_hotel_page(hotel_list, query)
    else
      :not_found
    end
  end

  def get_hotel_list(suggestions_page, query)
    if found_result_automatically?(suggestions_page)
      suggestions_page
    else
      get_correct_suggestion(suggestions_page, query)
    end
  end

  def found_result_automatically?(suggestions_page)
    suggestions_page.uri.to_s.include?('searchresults.html')
  end

  def get_correct_suggestion(suggestions_page, query)
    suggestions_page.search('.destination_name').each do |place_name|
      if similar_enough?(query, place_name.inner_html.strip)
        return @browser.click(place_name)
      end
    end

    nil
  end

  def navigate_from_hotel_list_to_hotel_page(hotel_list, query)
    hotel_list.search('.hotel_name_link').each do |hotel_name|
      if similar_enough?(query, hotel_name.inner_html.strip)
        return @browser.click(hotel_name)
      end
    end

    :not_found
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

  def build_query(google_places_data)
    "#{google_places_data['name']} #{get_locality(google_places_data)}"
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