require 'mechanize'
require 'unidecoder'

class BaseScraper
  def initialize
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def similar_enough?(a, b)
    a = a.downcase.to_ascii
    b = b.downcase.to_ascii

    # Experimental - removing forbidden words, but it doesn't work well
    # forbidden_words = %w{hotel resort restaurant place club}
    # a = remove_forbidden(forbidden_words, a)
    # b = remove_forbidden(forbidden_words, b)

    a.chars.any? and b.chars.any? and (
      a.start_with?(b) or
      b.start_with?(a) or
      a.sub('hotel', '').strip.start_with?(b.strip) or
      b.sub('hotel', '').strip.start_with?(a.strip)
    )
  end

  # def remove_forbidden(forbidden_words, name)
  #   words = name.split
  #   forbidden_words.each { |forbidden| words.delete(forbidden) }
  #   words.join(' ')
  # end

  def get_hotel_page(query)
    begin
      suggestions_page = get_suggestions_page(query)
    rescue Mechanize::ResponseCodeError => error_404
      return :not_found
    end

    navigate_from_suggestions_page_to_hotel_page(suggestions_page, query)
  end

  def get_suggestions_page(query)
    url = get_search_url(query)
    @browser.get(url)
  end

  def get_link_to(page)
    page.uri.to_s
  end

  def get_data(google_places_data)
    query = build_query(google_places_data)
    hotel_page = get_hotel_page(query)

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