require_relative 'tripadvisor_scraping'

describe TripAdvisorScraping do
  subject(:tripadvisor) { TripAdvisorScraping.new }

  before(:all) do
    @mechanize = Mechanize.new
  end

  def create_page(html_content)
    Mechanize::Page.new(nil, nil, html_content, nil, @mechanize)
  end

  describe '#found_place' do
    context 'target exists in page' do
      it 'returns true' do
        html = '<div class="title"><span>' \
          '<span class="highlighted">Hotel name</span>' \
          '</span></div>'

        page = create_page(html)
        expect(tripadvisor.found_place?(page, 'Hotel name')).to be true
      end
    end

    context 'target does not exist in page' do
      it 'returns false' do
        html = '<div class="title"><span>' \
          '<span class="highlighted">Hotel name</span>' \
          '</span></div>'
        
        page = create_page(html)
        expect(tripadvisor.found_place?(page, 'Unknown hotel')).to be false
      end
    end
  end

  describe '#get_container_div' do
    it 'gets the div containing the name of the hotel and the link to its page' do
      first_div = '<div class="title">Not ready to book?</div>'
      second_div = '<div class="title"><span><span class="highlighted">Pine Bay Holiday Resort</span></span></div>'
      page = create_page(first_div + second_div)

      expect(tripadvisor.get_container_div(page).to_html).to eq(second_div)
    end
  end
end