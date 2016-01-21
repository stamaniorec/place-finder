require 'mechanize'

require_relative 'base_scraper'

class BookingScraping < BaseScraper
  # def found_place?(page, target)
  #   page.search('.destination_name').any? do |place_name|
  #     similar_enough?(target, place_name.inner_html)
  #   end
  # end

  def extract_place_name(place_name)
    place_name.inner_html.strip
  end

  def get_search_url(place_name)
    "http://www.booking.com/search.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=#{place_name}/"
  end

  # http://www.booking.com/searchresults.bg.html?label=gen173nr-17EgZzZWFyY2goggJCAlhYSANiBW5vcmVmaBeIAQGYAQO4AQTIAQTYAQHoAQH4AQI;sid=ea4b880018b76df9d4aea9b92fc3df1e;dcid=4;dest_id=351699;dest_type=hotel&"


  def get_hotel_page(query)
    begin
    suggestions_page = get_suggestions_page(query)
    rescue Mechanize::ResponseCodeError => _404_error
      return :not_found
    end

    if suggestions_page.uri.to_s.include?('searchresults.html')
      hotel_list = suggestions_page
    else
      suggestions_page.search('.destination_name').each do |place_name|
      # navigate_to_hotel_page(suggestions_page, query)

        if similar_enough?(query, extract_place_name(place_name))
          
          p "#{query} and #{extract_place_name(place_name)} are similar enough"
          hotel_list = @browser.click(place_name)
          break
          # return navigate_to_hotel_page(hotel_list, query)

          # @browser.click(hotel_list.at('.hotel_name_link'))
          # end
        end
      end
    end
    return :not_found unless hotel_list
    navigate_from_hotel_list_to_hotel_page(hotel_list, query)

    # :not_found
  end

  def navigate_from_hotel_list_to_hotel_page(hotel_list, query)

  # end

  # def navigate_to_hotel_page(hotel_list, query)
    p 'navigating to hotel page'

    hotel_list.search('.hotel_name_link').each do |hotel_name|
      # p "hotel_name is #{hotel_name}"
      p "with innerhtml being #{hotel_name.inner_html.strip}"
      p "and query is #{query}"
      if similar_enough?(query, hotel_name.inner_html.strip) # if query.start_with?(hotel_name.inner_html.strip)
        p "clicking on #{hotel_name.inner_html.strip}"
        return @browser.click(hotel_name)
      end
    end
    :not_found
  end

  # def navigate_to_hotel_page(suggestions_page, query)
  #   hotel_list = @browser.click(suggestions_page.at('.destination_name'))
  #   @browser.click(hotel_list.at('.hotel_name_link'))
  # end

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