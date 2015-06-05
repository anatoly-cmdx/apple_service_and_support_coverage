# SimplexMobility

----

Scraper and parser for "Apple Service and Support Coverage" page

# scraper = AppleServiceAndSupportCoverageScraper.new(imei)
creates new scraper instance

# scraper.scrape
returns "Apple Service and Support Coverage" page source for given IMEI

returns empty string if IMEI is invalid

# scraper.parse
returns hash conforming to json schema (see spec/support/json/schemas/*.json)

returns nil if IMEI is invalid

hash example:

{:product_name=>"iPhone 5c", :product_sn=>"013977000323877", :is_purchase_date_valid=>true, :is_phone_support_active=>true, :is_service_coverage_active=>true, :dt_service_coverage_expiration=>"2016-08-10", :dt_phone_support_expiration=>"2016-08-10"}
