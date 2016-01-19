require 'mechanize'

class BaseScraper
  def initialize
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def similar_enough?(a, b)
    a.downcase!
    b.downcase!

    forbidden_words = %w{hotel resort restaurant place club}
    a = remove_forbidden(forbidden_words, a)
    b = remove_forbidden(forbidden_words, b)

    a.start_with?(*b.split)
  end

  def remove_forbidden(forbidden_words, name)
    words = name.split
    forbidden_words.each { |forbidden| words.delete(forbidden) }
    words.join(' ')
  end

  def get_suggestions_page(place_name)
    url = get_search_url(place_name)
    @browser.get(url)
  end

  def get_hotel_page(query)
    suggestions_page = get_suggestions_page(query)

    if found_place?(suggestions_page, query)
      navigate_to_hotel_page(suggestions_page, query)
    else
      :not_found
    end
  end

  def get_link_to(hotel_page)
    hotel_page.uri.to_s
  end

  def get_data(query)
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