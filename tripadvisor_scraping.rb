require 'mechanize'
require 'sanitize'

require_relative 'base_scraper'

class TripAdvisorScraping < BaseScraper
  def endpoint
    'http://www.tripadvisor.com/'
  end

  def found_place?(page, target)
    page.search('.title').any? do |place_name|
      Sanitize.clean(place_name.child.inner_html) == target
    end
  end

  def get_container_div(suggestions_page)
    suggestions_page.search('.title')[1]
  end

  def get_div_onclick_value(div)
    div['onclick'].match(/\/[\w-]+.html/).to_s
  end

  def get_target_link(onclick_value)
    endpoint + onclick_value
  end

  def navigate_to_hotel_page(suggestions_page, place_name)
    container_div = get_container_div(suggestions_page)
    onclick_value = get_div_onclick_value(container_div)
    @browser.get(get_target_link(onclick_value))
  end

  def get_rating_value(hotel_page)
    hotel_page.at('img[property=\'ratingValue\']').attribute('alt').inner_html rescue nil
  end

  def build_data(hotel_page, data)
    data.tap do |data|
      data[:rating_value] = get_rating_value(hotel_page)
    end
  end
end

a = TripAdvisorScraping.new
p a.get_data('Pine Bay Holiday Resort')