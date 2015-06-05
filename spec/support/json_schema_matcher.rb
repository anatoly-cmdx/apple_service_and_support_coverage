require 'json-schema'

RSpec::Matchers.define :match_schema do |schema|
  match do |json_string|
    schema_directory = "#{ Dir.pwd }/spec/support/json/schemas"
    schema_path = "#{ schema_directory }/#{ schema }.json"
    JSON::Validator.validate!(schema_path, json_string, strict: false)
  end
end
