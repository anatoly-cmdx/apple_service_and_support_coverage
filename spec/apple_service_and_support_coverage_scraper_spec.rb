require 'spec_helper'

require './apple_service_and_support_coverage_scraper'

RSpec.describe AppleServiceAndSupportCoverageScraper do
  let(:imei_with_coverage_active) { '013977000323877' }
  let(:imei_with_coverage_expired) { '013896000639712' }
  let(:valid_imei) { imei_with_coverage_expired }
  let(:invalid_imei) { '000000000000000' }

  describe '.scrape' do
    context 'with valid IMEI' do
      it 'returns page with header "Your Service and Support Coverage"' do
        scraper = AppleServiceAndSupportCoverageScraper.new(valid_imei)
        page = scraper.scrape
        expect(page).to include('Your Service and Support Coverage')
      end
    end

    context 'with invalid IMEI' do
      it 'returns nil' do
        scraper = AppleServiceAndSupportCoverageScraper.new(invalid_imei)
        page = scraper.scrape
        expect(page).to be_nil
      end
    end
  end

  describe '.parse' do
    let(:json_schema) { 'apple_service_and_support_coverage' }

    context 'with "repairs and service coverage" active' do
      let(:scraper_active) { AppleServiceAndSupportCoverageScraper.new(imei_with_coverage_active) }
      let!(:parsed_active) { scraper_active.parse }

      it 'returns hash conforming to json schema' do
        expect(parsed_active).to match_schema json_schema
      end

      it 'sets flag "service coverage is active" to true' do
        expect(parsed_active[:is_service_coverage_active]).to be true
      end

      it 'contains "estimated expiration date" in ISO8601 format ("YYYY-MM-DD")' do
        expect(parsed_active[:dt_service_coverage_expiration].length).to be(10)
      end
    end

    context 'with "repairs and service coverage" expired' do
      let(:scraper_expired) { AppleServiceAndSupportCoverageScraper.new(imei_with_coverage_expired) }
      let!(:parsed_expired) { scraper_expired.parse }

      it 'returns hash conforming to json schema' do
        expect(parsed_expired).to match_schema json_schema
      end

      it 'sets flag "service coverage is active" to false' do
        expect(parsed_expired[:is_service_coverage_active]).to be false
      end

      it 'returns nil for "estimated expiration date"' do
        expect(parsed_expired[:dt_service_coverage_expiration]).to be_nil
      end
    end

    context 'with invalid IMEI' do
      let(:scraper_invalid) { AppleServiceAndSupportCoverageScraper.new(:invalid_imei) }
      let!(:parsed_invalid) { scraper_invalid.parse }

      it 'returns nil' do
        expect(parsed_invalid).to be_nil
      end
    end
  end
end
