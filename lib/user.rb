class User
  include DataMapper::Resource
  
  property :uid, String,
    :key => true
  property :name, String
  property :access_token, String
  property :profile_picture_url, String
  
  has n, :comments
  
  def self.create_with_omniauth(auth)
    user=new
    user.uid = auth['uid']
    user.name = auth['info']['name']
    user.access_token = auth['credentials']['token']
    user.profile_picture_url=auth['info']['image']
    user.save
    user
  end
end


