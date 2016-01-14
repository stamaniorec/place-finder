require_relative 'booking_scraping'

describe BookingScraping do
  describe '#build_data' do
    it 'builds data from a given hotel page' do
      hotel_page = double
      data = {}
      booking = BookingScraping.new

      allow(hotel_page).to receive(:uri).and_return('a link')
      allow(booking).to receive(:get_stars).and_return(5)
      allow(booking).to receive(:get_location).and_return('На плажа')
      allow(booking).to receive(:get_score_word).and_return('Добър')
      allow(booking).to receive(:get_score_value).and_return(7.8)
      allow(booking).to receive(:get_booking_link).and_return('a link')

      result = {
        stars: 5,
        location_perk: 'На плажа',
        booking_score_word: 'Добър',
        booking_rating_score: 7.8,
        booking_link: 'a link'
      }

      expect(booking.build_data(hotel_page, data)).to eq(result)
    end
  end

  describe '#get_link_to' do
    it 'returns the URI of the given hotel page as a string' do
      booking = BookingScraping.new

      hotel_page = double
      uri = URI::HTTP.build({host: 'www.google.bg', path: ''})
      allow(hotel_page).to receive(:uri).and_return(uri)

      expect(booking.get_link_to(hotel_page)).to eq('http://www.google.bg')
    end
  end

  describe '#get_search_url' do
    it 'returns the search url for the given place name' do
      booking = BookingScraping.new
      place_name = 'place'
      result = 'http://www.booking.com/search.bg.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=place/'
      expect(booking.get_search_url(place_name)).to eq(result)
    end
  end

  describe '#get_stars' do
    before(:each) do
      @booking = BookingScraping.new
      @hotel_page = double
    end

    context 'has star information available' do
      it 'returns the number of stars of the hotel' do
        nokogiri_xml_element = {'title' => '5 звезди'}
        allow(@hotel_page).to receive(:at).with('.star_track').and_return(nokogiri_xml_element)
        expect(@booking.get_stars(@hotel_page)).to eq(5)
      end
    end

    context '.star_track has different inner html from usual' do
      it 'returns 0' do
        nokogiri_xml_element = {'title' => 'Хотел с 5 звезди'}
        allow(@hotel_page).to receive(:at).with('.star_track').and_return(nokogiri_xml_element)
        expect(@booking.get_stars(@hotel_page)).to eq(0)
      end
    end

    context 'there is no element with class star_track in the html document' do
      it 'returns nil' do
        nokogiri_xml_element = {'title' => 'Хотел с 5 звезди'}
        allow(@hotel_page).to receive(:at).with('.star_track').and_return(nil)
        expect(@booking.get_stars(@hotel_page)).to eq(nil)
      end
    end
  end

  describe '#found_place?' do
    before(:each) do
      @booking = BookingScraping.new
      @page = double
      place = double
      allow(place).to receive(:inner_html).and_return('foo')
      allow(@page).to receive(:search).with('.destination_name').and_return([place])
    end

    context 'target exists in page' do
      it 'returns true' do
        expect(@booking.found_place?(@page, 'foo')).to eq(true)
      end
    end

    context 'target doe not exist in page' do
      it 'returns true' do
        expect(@booking.found_place?(@page, 'bar')).to eq(false)
      end
    end
  end
end