require 'date'
require 'nokogiri'
require 'json/ext'
require_relative './lib/capybara_webkit_headless'

class AppleServiceAndSupportCoverageScraper
  include CapybaraWebkitHeadless

  def initialize(hardware_serial_number)
    @hardware_serial_number = hardware_serial_number
  end

  def scrape
    return @scraped_page if @scraped_page
    @scraped_page = ''

    new_session(allowed_urls: allowed_urls)

    visit 'https://selfsolve.apple.com/agreementWarrantyDynamic.do'

    within '#serialnumbercheck' do
      fill_in 'sn', with: @hardware_serial_number
    end
    click_on 'warrantycheckbutton'

    page_header = page.first('#wcTitleStatus')
    if page_header && page_header.text.strip == 'Your Service and Support Coverage'
      @scraped_page = page.source
    end
    # If page_header does not match then it's not the page we are looking for
    # Should we throw an error or just silently return empty string (or nil)?

    @scraped_page
  end

  def parse
    return @parsed_page if @parsed_page

    @scraped_page = scrape unless @scraped_page

    # What if @scraped_page is empty?
    # Should we return nil, {}, or {product_name: nil, product_sn: nil, ...}?
    return nil if @scraped_page.empty?

    @html = Nokogiri::HTML(@scraped_page)

    build_hash parse_elements
  end

  protected

  def build_hash(parsed)
    @parsed_page = {
      product_name: parsed[:product_name][:text],
      product_sn:   parsed[:product_sn][:text],
      is_purchase_date_valid: parsed[:registration][:has_true_id],
      is_phone_support_active: parsed[:phone_support][:has_true_id],
      is_service_coverage_active: parsed[:service_coverage][:has_true_id]
    }

    dt = expiration_date(parsed[:service_details][:el])
    @parsed_page.merge!(dt_service_coverage_expiration: dt) if dt

    dt = expiration_date(parsed[:phone_details][:el])
    @parsed_page.merge!(dt_phone_support_expiration: dt) if dt

    @parsed_page
  end

  def parse_elements
    elements = {}
    elements_paths.each do |name, path|
      elements[name] = parse_element(path)
    end
    elements
  end

  def parse_element(path)
    el = @html.at_css(path)
    element = { el: el }
    begin
      element.merge!(
        has_true_id: el.attributes['id'].value.include?('-true'),
        text: el.text.strip
      )
    end
    element
  end

  def expiration_date(element, adjacent_text = 'Estimated Expiration Date: ')
    begin
      dt = element.children
           .map { |el| el.text.strip }
           .find { |s| s =~ /#{ adjacent_text }/ }
           .gsub(adjacent_text, '')
      dt_date = Date.parse(dt).iso8601
    rescue
      dt_date = nil
    end
    dt_date
  end

  def elements_paths
    {
      product_name:     '#product #productname',
      product_sn:       '#product #productsn',
      registration:     '#results #registration h3[style=""]',
      phone_support:    '#results #phone h3[style=""]',
      phone_details:    '#results #phone #phone-text',
      service_coverage: '#results #hardware h3[style=""]',
      service_details:  '#results #hardware #hardware-text'
    }
  end

  def allowed_urls
    %w(selfsolve.apple.com www.apple.com ssl.apple.com km.support.apple.com.edgekey.net)
  end
end
