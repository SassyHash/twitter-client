require 'oauth'
require 'json'
require 'rest-client'
require 'nokogiri'
require 'launchy'

class TwitterClient

  attr_reader :access_token
  CONSUMER_KEY = "rT88bd0chOOflPUQpekUzg"
  CONSUMER_SECRET = "IgS0CSLsxi1kqcYbkubdGlxYI1Zqs49BNsVHLcjl4"

  # Request token URL https://api.twitter.com/oauth/request_token
  # Authorize URL https://api.twitter.com/oauth/authorize
  # Access token URL  https://api.twitter.com/oauth/access_token
  # Callback URL  None

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "http://twitter.com")

def run
    puts "Welcome to Brittany & Jason twitter interface!"
    puts "Here are your abundant command options"
    # ***
    # NR Why not split this up into multiple puts? A natural
    # break point would be at the \n. This line seems excessively
    # long.
    # ***
    puts " Post a status: p your status \n Send a direct message: dm person message \n Access your timeline: me \n Other person's timeline: t screenname"
    access_token = get_token("twitter_token")
    input = ""
    while input != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!" 
        when 'p' then post_status(access_token, parts[1..-1].join(" "))
        when 'dm' then send_dm(access_token, parts[1], parts[2..-1].join(" "))
        when 'me' then user_timeline(access_token)
        when 't' then user_timeline(access_token, parts[1])
        else
          puts "Sorry, I do not know how to #{command}"
      end
    end
  end

  def get_access_token
    # send user to twitter URL to authorize application
    request_token = CONSUMER.get_request_token
    Launchy.open(request_token.authorize_url)

    # because we don't use a redirect URL; user will receive an "out of
    # band" verification code that the application may exchange for a
    # key; ask user to give it to us
    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp

    # ask the oauth library to give us an access token, which will allow
    # us to make requests on behalf of this user
    access_token = request_token.get_access_token(
        :oauth_verifier => oauth_verifier )
  end
def get_token(token_file)
  # We can serialize token to a file, so that future requests don't need
  # to be reauthorized.

  if File.exist?(token_file)
    File.open(token_file) { |f| YAML.load(f) }
  else
    access_token = get_access_token
    File.open(token_file, "w") { |f| YAML.dump(access_token, f) }

    access_token
  end
end
  # fetch a user's timeline
  def user_timeline(access_token, screen=nil)
    # the access token class has methods `get` and `post` to make
    # requests in the same way as RestClient, except that these will be
    # authorized.
    p screen
    if screen==nil
      timeline = access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json").body
    else
      timeline = access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{screen}").body
    end
      timeline = JSON.parse(timeline)

      puts "#{timeline[0]["id"]}\'s Twitter timeline: "
      20.times do |num|
        # p timeline[num].keys
        puts "Tweet #{num+1}"
        puts timeline[num].values_at("created_at","text")
      end

    # p Nokogiri::HTML(timeline).xpath("//text()".to_s)

  end

  def post_status(access_token, message)
    p message
    post = access_token.post("https://api.twitter.com/1.1/statuses/update.json", :status => message)
    puts post
  end

  def send_dm(access_token, recipient, message)
    post = access_token.post("https://api.twitter.com/1.1/direct_messages/new.json", :screen_name => recipient, :text => message)
  p message
  puts post
  end
end