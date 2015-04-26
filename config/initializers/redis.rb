if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  $redis = Redis.new(:url => uri)
else
  $redis = Redis.new(:host => 'localhost', :port => '6379')
end