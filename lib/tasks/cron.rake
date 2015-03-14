desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  #client = Twitter::Client.new do |config|
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['consumer_key']
    config.consumer_secret     = ENV['consumer_secret']
    config.access_token        = ENV['oauth_token']
    config.access_token_secret = ENV['oauth_token_secret']
  end
  tweet_text = "d @JohnB Unable to get the pizza of the day."
  begin
    tweet_text = PizzaOfTheDay.new.tweet_text
  rescue Exception => e
    tweet_text = "d @JohnB #{e}"[0..139]
  end
  tweet_text ||= "d @JohnB PizzaOfTheDay.new.tweet_text returned nil."
  puts client.update(tweet_text).inspect
end
