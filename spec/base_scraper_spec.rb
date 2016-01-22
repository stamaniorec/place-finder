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
    it 'returns true for Ephesia Hotel Kusadasi and Ephesia Hotel' do
      a = 'Ephesia Hotel Kusadasi'
      b = 'Ephesia Hotel'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns false for wombat\'s CITY HOSTEL Budapest and ...' do
      a = 'wombat\'s CITY HOSTEL Budapest'
      b = 'Hotel Berlin Budapest'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns false for Hilton Berlin and Hotel Berlin Budapest' do
      a = 'Hilton Berlin'
      b = 'Hotel Berlin Budapest'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns true for Hotel Berlin Budapest and Hotel Berlin' do
      a = 'Hotel Berlin Budapest'
      b = 'Hotel Berlin'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns false for Hilton Berlin and Hotel Berlin' do
      a = 'Hilton Berlin'
      b = 'Hotel Berlin'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns false for Jurys Inn Hotel Prague and hotel berlin ...' do
      a = 'Jurys Inn Hotel Prague'
      b = 'hotel berlin budapest'
      expect(base_scraper.similar_enough?(a, b)).to be false
    end

    it 'returns true for Ephesia Holiday Beach Club Kusadasi and ...' do
      a = 'Ephesia Holiday Beach Club Kusadasi'
      b = 'Ephesia Holiday Beach Club'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns false for blah blah berlin and hotel berlin' do
      a = 'blah blah berlin'
      b = 'hotel berlin'
      expect(base_scraper.similar_enough?(a,b)).to be false
    end

    it 'returns false for hotel palazzo zichy and hotel berlin budapest' do
      a = 'hotel palazzo zichy'
      b = 'hotel berlin budapest'
      expect(base_scraper.similar_enough?(a,b)).to be false
    end

    it 'returns false for berlin grande and hotel berlin' do
      a = 'berlin grande'
      b = 'hotel berlin'
      expect(base_scraper.similar_enough?(a,b)).to be false
    end

    it 'returns true for Olympik Tristar and Hotel Olympik Tristar' do
      a = 'Olympik Tristar'
      b = 'Hotel Olympik Tristar'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    it 'returns true for olympik tristar  and Hotel Olympik Tristar' do
      a = 'olympik tristar '
      b = 'Hotel Olympik Tristar'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end

    pending do
      a = 'Ephesia Hotel - All Inclusive'
      b = 'Ephesia Hotel Kusadasi'
      expect(base_scraper.similar_enough?(a, b)).to be true
    end
  end

  describe '#get_hotel_page' do
    context 'hotel page not found in suggestions page' do
      it 'returns :not_found' do
        allow(base_scraper).to receive(:get_suggestions_page)
        allow(base_scraper).to receive(:navigate_from_suggestions_page_to_hotel_page).and_return(:not_found)
        expect(base_scraper.get_hotel_page('query')).to eq(:not_found)
      end
    end

    context 'searching yields a 404 error' do
      it 'returns :not_found' do
        page = double
        allow(page).to receive(:code).and_return(404)
        exception = Mechanize::ResponseCodeError.new(page)
        allow(base_scraper).to receive(:get_suggestions_page).and_raise(exception)
        expect(base_scraper.get_hotel_page('query')).to eq(:not_found)
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