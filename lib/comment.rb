class Comment
  include DataMapper::Resource
  property :id, Serial
  property :body, Text
  property :date, DateTime
  property :created_at, DateTime
  
  belongs_to :asset
  belongs_to :user
end