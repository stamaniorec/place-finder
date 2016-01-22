require_relative '../scrapers/tripadvisor_scraping'
require 'nokogiri'

describe TripAdvisorScraping do
  subject(:tripadvisor) { TripAdvisorScraping.new }

  before(:all) do
    @mechanize = Mechanize.new
  end

  def create_page(html_content)
    Mechanize::Page.new(nil, nil, html_content, nil, @mechanize)
  end

  # describe '#found_place' do
  #   context 'target exists in page' do
  #     it 'returns true' do
  #       html = '<div class="title"><span>' \
  #         '<span class="highlighted">Hotel name</span>' \
  #         '</span></div>'

  #       page = create_page(html)
  #       expect(tripadvisor.found_place?(page, 'Hotel name')).to be true
  #     end
  #   end

  #   context 'target does not exist in page' do
  #     it 'returns false' do
  #       html = '<div class="title"><span>' \
  #         '<span class="highlighted">Hotel name</span>' \
  #         '</span></div>'
        
  #       page = create_page(html)
  #       expect(tripadvisor.found_place?(page, 'Unknown hotel')).to be false
  #     end
  #   end
  # end

  # describe '#get_container_div' do
  #   it 'gets the div containing the name of the hotel and the link to its page' do
  #     first_div = '<div class="title">Not ready to book?</div>'
  #     second_div = '<div class="title"><span><span class="highlighted">Pine Bay Holiday Resort</span></span></div>'
  #     page = create_page(first_div + second_div)

  #     expect(tripadvisor.get_container_div(page).to_html).to eq(second_div)
  #   end
  # end

  describe '#get_div_onclick_value' do
    it 'gets the div onclick attribute value from the container div' do
      page = Nokogiri::HTML('<div class="title" onclick="blabla..., /myonclickvalue.html">...</div>')
      div = page.css('div').first
      expect(tripadvisor.get_div_onclick_value(div)).to eq("/myonclickvalue.html")
    end
  end

  describe '#get_search_url' do
    it 'returns the search url for the given query' do
      allow(tripadvisor).to receive(:endpoint).and_return('endpoint')
      expect(tripadvisor.get_search_url('query')).to eq('endpointSearch?q=query')
    end
  end

  describe '#endpoint' do
    it 'returns the tripadvisor endpoint url' do
      expect(tripadvisor.endpoint).to eq('http://www.tripadvisor.com/')
    end
  end

  describe '#set_success' do
    it 'adds pair tripadvisor_status: :ok in given data hash' do
      expect(tripadvisor.set_success({})).to eq({tripadvisor_status: :ok})
    end
  end

  describe '#set_error' do
    it 'adds pair tripadvisor_status: :not_found in given data hash' do
      expect(tripadvisor.set_error({})).to eq({tripadvisor_status: :not_found})
    end
  end

  describe '#build_data' do
    it 'builds data from a given hotel page' do
      data = {}

      hotel_page = double
      allow(hotel_page).to receive(:uri).and_return('a link')
      allow(tripadvisor).to receive(:get_rating_value).and_return(4.5)
      allow(tripadvisor).to receive(:get_tags).and_return(['tag1', 'tag2'])
      allow(tripadvisor).to receive(:get_rank_text).and_return('#33 of 58 hotels in wherever')
      allow(tripadvisor).to receive(:get_highlight_tags).and_return(['Free parking', 'Luxury'])
      allow(tripadvisor).to receive(:get_link_to).and_return('a link')

      result = {
        tripadvisor_rating_score: 4.5,
        tags: ['tag1', 'tag2'],
        tripadvisor_rank_text: '#33 of 58 hotels in wherever',
        tripadvisor_highlights_tags: ['Free parking', 'Luxury'],
        tripadvisor_link: 'a link'
      }

      expect(tripadvisor.build_data(hotel_page, data)).to eq(result)
    end
  end
end