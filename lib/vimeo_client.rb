class VimeoClient

  def self.fetch_oauth
    @base = Vimeo::Advanced::Base.new(ENV["vimeo_id"], ENV["vimeo_secret"])
    request_token = @base.get_request_token
    request_token.secret
  end

  def self.fetch_url
    @base.authorize_url
  end

  def self.get_base
    @base = Vimeo::Advanced::Base.new(ENV["vimeo_id"], ENV["vimeo_secret"])
  end

  def self.save_latest  # called upon login or refresh, get latest 10 pages
    VideoGet.perform_async $redis.get('vimeo_token'), $redis.get('vimeo_secret')
  end

  def self.save_credentials token, secret
    $redis.set('vimeo_token', token)
    $redis.set('vimeo_secret', secret)
  end

  def self.delete_credentials
    $redis.del('vimeo_token')
    $redis.del('vimeo_secret')
  end

end
