require 'mechanize'
require 'sanitize'

require_relative 'base_scraper'

class TripAdvisorScraping < BaseScraper
  def endpoint
    'http://www.tripadvisor.com/'
  end

  def get_search_url(place_name)
    "#{endpoint}Search?q=#{place_name}"
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

  def get_tags(hotel_page)
    hotel_page.search('.tag').drop(1).map(&:inner_html)
  end

  def get_rank_text(hotel_page)
    Sanitize.clean(hotel_page.at('.rank_text').inner_html.strip)
  end

  def get_highlight_tags(hotel_page)
    container_div = hotel_page.at('.amenity_cnt')
    property_tags_wrap_div = container_div.children[3]
    property_tags_ul = property_tags_wrap_div.children[1]

    property_tags_ul.children.map do |li|
      Sanitize.clean(li.inner_html).strip
    end.select do |tag|
      not tag.empty?
    end
  end

  def set_error(data)
    data.tap { |data| data[:tripadvisor_status] = :not_found }
  end

  def set_success(data)
    data.tap { |data| data[:tripadvisor_status] = :ok }
  end

  def build_data(hotel_page, data)
    data.tap do |data|
      data[:tripadvisor_rating_score] = get_rating_value(hotel_page)
      data[:tags] = get_tags(hotel_page)
      data[:tripadvisor_rank_text] = get_rank_text(hotel_page)
      data[:tripadvisor_highlights_tags] = get_highlight_tags(hotel_page)
      data[:tripadvisor_link] = get_link_to(hotel_page)
    end
  end
end