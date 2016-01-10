require 'mechanize'

class BookingScraping
  def get_data(place_name)
    url = "http://www.booking.com/search.bg.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=ephesia%20holiday%20beach/"

    browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end

    browser.get(url) do |page|
      page.search('.destination_name').each do |place_name|
        p place_name.inner_html
      end
    end
  end
end

