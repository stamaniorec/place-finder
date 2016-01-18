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

    forbidden = %w{hotel resort restaurant place club}
    words_in_a = a.split # hotel hilton
    words_in_b = b.split # hotel berlin

    forbidden.each { |word| words_in_a.delete(word) }
    forbidden.each { |word| words_in_b.delete(word) }

    a = words_in_a.join(" ")
    b = words_in_b.join(" ")

    # p 'HUEHUEHUEHEU'
    # p a
    # p b
    # words_in_a.any? { |word| b.include?(word) } or words_in_b.any? { |word| a.include?(word) }
    # a.chars.any? and b.chars.any? and (a.start_with?(b) or b.start_with?(a))

    # a.chars.any? and b.chars.any? and (a.start_with?(*b.split) or b.start_with?(*a.split))
    p 'here comes a'
    p a
    p 'words in b'
    p b.split
    p "therefore -> #{a.chars.any? and b.chars.any? and (a.start_with?(*b.split))}"
    a.chars.any? and b.chars.any? and (a.start_with?(*b.split))

    # a.chars.any? and b.chars.any? and (words_in_a.any? { |word| b.include?(word) } or words_in_b.any? { |word| a.include?(word) })
  end

  def get_suggestions_page(place_name)
    url = get_search_url(place_name)
    @browser.get(url)
  end

  def get_hotel_page(place_name)
    suggestions_page = get_suggestions_page(place_name)

    p "looking for #{place_name}" # change place_name to query cos it's the whole thingy
    if found_place?(suggestions_page, place_name)
      # p "at page #{suggestions_page.uri.to_s} looking for #{place_name}"
      navigate_to_hotel_page(suggestions_page, place_name)
    else
      :not_found
    end
  end

  def get_link_to(hotel_page)
    hotel_page.uri.to_s
  end

  def get_data(place_name, locality) # change arg to just one - the query
    hotel_page = get_hotel_page(place_name + ' ' + locality) # and here accordingly

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