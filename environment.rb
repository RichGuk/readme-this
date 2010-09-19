# Database setup.
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{File.expand_path(File.dirname(__FILE__))}/development.db")

# Load Models
require 'models'
DataMapper.finalize
