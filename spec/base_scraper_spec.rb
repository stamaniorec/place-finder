require_relative '../scrapers/base_scraper'

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

  describe '#similar_enough?' do
    it 'returns true' do
      a = 'Ephesia Hotel'
      b = 'Ephesia Hotel Kusadasi'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns false' do
      a = 'wombat\'s CITY HOSTEL Budapest'
      b = 'Hotel Berlin Budapest'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns false' do
      a = 'Hilton Berlin'
      b = 'Hotel Berlin Budapest'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns true' do
      a = 'Ephesia Hotel - All Inclusive'
      b = 'Ephesia Hotel Kusadasi'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns true' do
      a = 'Hotel Berlin'
      b = 'Hotel Berlin Budapest'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns false' do
      a = 'Hilton Berlin'
      b = 'Hotel Berlin'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns false' do
      a = 'Jurys Inn Hotel Prague'
      b = 'hotel berlin budapest'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns true' do
      a = 'Ephesia Holiday Beach Club'
      b = 'Ephesia Holiday Beach Club Kusadasi'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns false' do
      a = 'blah blah berlin'
      b = 'hotel berlin'
      expect(base_scraper.similar_enough?(a,b)).to be false
    end

    it 'returns false' do
      a = 'hotel palazzo zichy'
      b = 'hotel berlin budapest'
      expect(base_scraper.similar_enough?(a,b)).to be false
    end

    pending do
      a = 'berlin grande'
      b = 'hotel berlin'
      expect(base_scraper.similar_enough?(a,b)).to be false
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
    it 'returns a hash' do
      allow(base_scraper).to receive(:get_hotel_page)
      allow(base_scraper).to receive(:set_success)
      allow(base_scraper).to receive(:build_data)
      expect(base_scraper.get_data('name')).to be_a Hash
    end
  end
end