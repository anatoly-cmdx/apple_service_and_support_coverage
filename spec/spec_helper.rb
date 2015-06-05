Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
