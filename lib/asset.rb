class Asset
    include DataMapper::Resource

    property :embed_code, String , 
      :key => true
    property :name, String
    property :description, Text
    property :preview_image_url, String
    has n, :comments
end
