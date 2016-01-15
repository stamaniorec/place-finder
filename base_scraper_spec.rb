require_relative 'base_scraper'

describe BaseScraper do
  subject(:base_scraper) { BaseScraper.new }

  it 'responds to get_data' do
    expect(base_scraper.respond_to?(:get_data)).to be true
  end

  describe '#initialize' do
    it 'creates a fake browser' do
      browser = base_scraper.instance_variable_get(:@browser)
      expect(browser.respond_to?(:get)).to be true
    end
  end

  describe '#get_hotel_page' do
    context 'hotel page not found' do
      it 'returns :not_found' do
        allow(base_scraper).to receive(:get_search_url).and_return('myurl')
        allow(base_scraper).to receive(:get_suggestions_page).and_return('page')
        allow(base_scraper).to receive(:found_place?).and_return(false)
        expect(base_scraper.get_hotel_page('myplacename')).to eq(:not_found)
      end
    end
  end

  describe '#get_link_to' do
    it 'returns the URI of the given hotel page as a string' do
      booking = BaseScraper.new

      hotel_page = double
      uri = URI::HTTP.build({host: 'www.google.bg', path: ''})
      allow(hotel_page).to receive(:uri).and_return(uri)

      expect(booking.get_link_to(hotel_page)).to eq('http://www.google.bg')
    end
  end

  describe '#get_data' do
    context 'place name exists, page is found' do
      it 'builds hash with key :status equal to :ok' do
        allow(base_scraper).to receive(:get_hotel_page).and_return('page')
        allow(base_scraper).to receive(:build_data).and_return(nil)
        expect(base_scraper.get_data('name')).to include({status: :ok})
      end
    end

    context 'place does not exist, page is not found' do
      it 'builds hash with key :status equal to :not_found' do
        place_name = 'myplacename'
        allow(base_scraper).to receive(:get_hotel_page).with(place_name).and_return(:not_found)
        expect(base_scraper.get_data(place_name)).to include({status: :not_found})
      end
    end
  end
end