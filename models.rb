class Readme
  include DataMapper::Resource

  property :id, Serial, :serial => true
  property :private_id, String, :index => true
  property :format, String, :required => true
  property :contents, Text, :required => true

  property :created_at, DateTime
  property :updated_at, DateTime
end
