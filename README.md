# SimplexMobility

----

Scraper and parser for "Apple Service and Support Coverage" page

`scraper = ServiceAndSupportCoverageScraper.new(imei)`

* creates new scraper instance

----

`.scrape`

* returns "Apple Service and Support Coverage" page source for given IMEI

* returns nil if IMEI is invalid

----

`.parse`

* returns hash conforming to json schema (see spec/support/json/schemas/*.json)

* returns nil if IMEI is invalid

----

### hash examples for "repairs and service coverage"

#### active:

`{:product_name=>"iPhone 5c", :product_sn=>"013977000323877", :is_purchase_date_valid=>true, :is_phone_support_active=>true, :is_service_coverage_active=>true, :dt_service_coverage_expiration=>"2016-08-10", :dt_phone_support_expiration=>"2016-08-10"}`

#### expired:

`{:product_name=>"iPhone 5c", :product_sn=>"013896000639712", :is_purchase_date_valid=>true, :is_phone_support_active=>false, :dt_service_coverage_expiration=>nil, :is_service_coverage_active=>false, :dt_phone_support_expiration=>nil}`
