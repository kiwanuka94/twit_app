require 'oauth/request_proxy/typhoeus_request'

class TwitterService
  def self.message(feedback)
    ".@#{feedback.recipient_handle}, '#{feedback.text}' --Anon"
  end

  def self.tweet!(message)
    body = { "text": message(message) }

    @consumer = OAuth::Consumer.new(
      ENV['twitter_consumer_key'],
      ENV['twitter_consumer_secret'],
    )
    @token = OAuth::Token.new(ENV['twitter_oauth_token'], ENV['twitter_oauth_secret'])
    options = {
      method: :post,
      headers: {
        "content-type" => "application/json"
      },
      body: body.to_json
    }

    oauth_params = {:consumer => @consumer, :token => @token}

    hydra = Typhoeus::Hydra.new
    url = 'https://api.twitter.com/2/tweets'
    req = Typhoeus::Request.new(url, options)
    oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => url))
    req.options[:headers].merge!({"Authorization" => oauth_helper.header})

    response = req.run

    if response.success?
      tweet_id_now = JSON.parse(response.body)['data']['id']
      tweet_url_now = "https://twitter.com/twitter/status/#{tweet_id_now}"
      message.update(tweet_id: tweet_id_now, tweet_url: tweet_url_now)

      puts "Credentials work! Tweet:"
      puts JSON.pretty_generate(JSON.parse(response.body))


    else
      puts "Credentials failed, please try generating again."
    end

  end
end
