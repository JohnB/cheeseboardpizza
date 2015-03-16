desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  def create_client_connection
    #client = Twitter::Client.new do |config|
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['consumer_key']
      config.consumer_secret     = ENV['consumer_secret']
      config.access_token        = ENV['oauth_token']
      config.access_token_secret = ENV['oauth_token_secret']
    end
  end

  def prepare_message
    tweet_text = "d @JohnB Unable to get the pizza of the day."
    begin
      tweet_text = PizzaOfTheDay.new.tweet_text
    rescue Exception => e
      tweet_text = "d @JohnB #{e}"[0..139]
    end
  end

  client = create_client_connection
  message = prepare_message || "d @JohnB PizzaOfTheDay.new.tweet_text returned nil."

  ## Uncomment during tests, to get around twitter blocking duplicate test messages
  message = Time.now.strftime("%H:%M:%S #{prepare_message}") if ENV['RAILS_ENV'] == "development"

  puts ENV['RAILS_ENV']
  puts message
  puts client.update(message).inspect
end

