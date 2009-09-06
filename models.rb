class Readme
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :private_id, String, :index => true
  property :format, String, :nullable => false
  property :contents, Text, :nullable => false

  property :created_at, DateTime
  property :updated_at, DateTime
end