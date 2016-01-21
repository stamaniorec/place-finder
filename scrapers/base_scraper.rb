require 'mechanize'
require 'unidecoder'

class BaseScraper
  def initialize
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def similar_enough?(a, b)
    a.downcase!
    b.downcase!

    # forbidden_words = %w{hotel resort restaurant place club}
    # a = remove_forbidden(forbidden_words, a)
    # b = remove_forbidden(forbidden_words, b)

    # a.start_with?(*b.split)
    # p '--- --- --- --- ---'
    a = a.to_ascii
    b = b.to_ascii
    
    # forbidden_words = %w{hotel resort restaurant place club}
    # a = remove_forbidden(forbidden_words, a)
    # b = remove_forbidden(forbidden_words, b)

    # p a
    # p b
    # a == b

    p 'oburni mi vnimanie'
    p "a.sub('hotel', '').strip => #{a.sub('hotel', '').strip}"
    p "b.sub('hotel', '').strip => #{b.sub('hotel', '').strip.start_with?(a)}"

    a.chars.any? and b.chars.any? and (a.start_with?(b) or b.start_with?(a) or a.sub('hotel', '').strip.start_with?(b.strip) or b.sub('hotel', '').strip.start_with?(a.strip))
  end

  def remove_forbidden(forbidden_words, name)
    words = name.split
    forbidden_words.each { |forbidden| words.delete(forbidden) }
    words.join(' ')
  end

  def get_suggestions_page(place_name)
    url = get_search_url(place_name)
    @browser.get(url) 
    # @browser.get "http://www.booking.com/searchresults.bg.html?label=gen173nr-17EgZzZWFyY2goggJCAlhYSANiBW5vcmVmaBeIAQGYAQO4AQTIAQTYAQHoAQH4AQI;sid=ea4b880018b76df9d4aea9b92fc3df1e;dcid=4;dest_id=351699;dest_type=hotel&"
  end

  # def get_hotel_page(query)
    # p "query is #{query}"
    # suggestions_page = get_suggestions_page(query)

    # navigate_to_hotel_page(suggestions_page, query)

    # p suggestions_page.uri.to_s

    # suggestions_page.search('.destination_name').each do |place_name|
    #   navigate_to_hotel_page(suggestions_page, query)

    #   if similar_enough?(query, extract_place_name(place_name))
        
    #     # p "#{query} and #{extract_place_name(place_name)} are similar enough"
    #     hotel_list = @browser.click(place_name)
    #     return navigate_to_hotel_page(hotel_list, query)

    #     # @browser.click(hotel_list.at('.hotel_name_link'))
    #     # end
    #   end
    # end

    # :not_found

    
    

    # if found_place?(suggestions_page, query)
    #   navigate_to_hotel_page(suggestions_page, query)
    # else
    #   :not_found
    # end
  # end

  def get_link_to(hotel_page)
    hotel_page.uri.to_s
  end

  def get_data(query)
    hotel_page = get_hotel_page(query)
    # p "hotel page uri is #{hotel_page.uri.to_s}"

    {}.tap do |data|
      if hotel_page == :not_found
        set_error(data)
      else
        set_success(data)
        build_data(hotel_page, data)
      end
    end
  end
end