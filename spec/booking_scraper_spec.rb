require_relative '../scrapers/booking_scraper'

describe BookingScraper do
  subject(:booking) { BookingScraper.new }
  let(:hotel_page) { double }

  describe '#build_data' do
    it 'builds data from a given hotel page' do
      data = {}

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

  describe '#get_search_url' do
    it 'returns the search url for the given query' do
      place_name = 'place'
      result = 'http://www.booking.com/search.html?si=ai%2Cco%2Cci%2Cre%2Cdi&ss=place/'
      expect(booking.get_search_url(place_name)).to eq(result)
    end
  end

  describe '#get_stars' do
    context 'has star information available' do
      it 'returns the number of stars of the hotel' do
        nokogiri_xml_element = {'title' => '5 звезди'}
        allow(hotel_page).to receive(:at).with('.star_track').and_return(nokogiri_xml_element)
        expect(booking.get_stars(hotel_page)).to eq(5)
      end
    end

    context '.star_track has different inner html from usual' do
      it 'returns 0' do
        nokogiri_xml_element = {'title' => 'Хотел с 5 звезди'}
        allow(hotel_page).to receive(:at).with('.star_track').and_return(nokogiri_xml_element)
        expect(booking.get_stars(hotel_page)).to eq(0)
      end
    end

    context 'there is no element with class star_track in the html document' do
      it 'returns nil' do
        nokogiri_xml_element = {'title' => 'Хотел с 5 звезди'}
        allow(hotel_page).to receive(:at).with('.star_track').and_return(nil)
        expect(booking.get_stars(hotel_page)).to eq(nil)
      end
    end
  end

  describe '#set_success' do
    it 'adds pair booking_status: :ok in given data hash' do
      expect(booking.set_success({})).to eq({booking_status: :ok})
    end
  end

  describe '#set_error' do
    it 'adds pair booking_status: :not_found in given data hash' do
      expect(booking.set_error({})).to eq({booking_status: :not_found})
    end
  end

  describe '#navigate_from_suggestions_page_to_hotel_page' do
    before do
      @suggestions_page = double
      @query = double
    end

    context 'hotel found on suggestions page' do
      it 'delegates finding the hotel page to the navigate_from_hotel_list_to_hotel_page method' do
        hotel_list = double

        allow(booking).to receive(:get_hotel_list)
                          .with(@suggestions_page, @query)
                          .and_return(hotel_list)

        allow(booking).to receive(:navigate_from_hotel_list_to_hotel_page)
                          .with(hotel_list, @query)
                          .and_return('something')

        expectation = booking.navigate_from_suggestions_page_to_hotel_page(@suggestions_page, @query)
        expect(expectation).to eq('something')
      end
    end

    context 'hotel is not found on suggestions page' do
      it 'returns :not_found' do
        allow(booking).to receive(:get_hotel_list)
                          .with(@suggestions_page, @query)
                          .and_return(nil)

        expectation = booking.navigate_from_suggestions_page_to_hotel_page(@suggestions_page, @query)
        expect(expectation).to eq(:not_found)
      end
    end
  end

  describe '#get_hotel_list' do
    before do
      @suggestions_page = double
      @query = double
    end

    context 'result was found automatically' do
      it 'returns the page it hit which is the hotel list not the suggestions page' do
        allow(booking).to receive(:found_result_automatically?)
                          .with(@suggestions_page)
                          .and_return(true)

        expect(booking.get_hotel_list(@suggestions_page, @query)).to eq(@suggestions_page)
      end
    end

    context 'result was not found automatically, browser was redirected to suggestions page' do
      it 'returns the correct suggestion' do
        allow(booking).to receive(:found_result_automatically?)
                          .with(@suggestions_page)
                          .and_return(false)

        allow(booking).to receive(:get_correct_suggestion)
                          .with(@suggestions_page, @query)
                          .and_return('result')

        expect(booking.get_hotel_list(@suggestions_page, @query)).to eq('result')
      end
    end
  end
end
