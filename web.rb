require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'
require 'json'
require 'logger'
logger = Logger.new(STDOUT)
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
  end
get '/callback' do
  puts "success"
end

post '/callback' do
  body = request.body.read
  puts "body debugging"
  puts body
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  begin
  logger.debug("events body=#{events.first}") 
  rescue => e
    logger.debug(e)
  end
  begin
  events.each do |event|
    begin
      if event.is_a?(Line::Bot::Event)
        logger.debug("data comes here")
        message = {}

        logger.debug("#{event['message']}")

        logger.debug("set message text")
        logger.debug("#{event['message']['text']}")
        begin
        message = {
          type: 'text',
          text: event['message']['text']
        }
        rescue => e
          logger.warn(e)
        end
        begin
          client.reply_message(event['replyToken'], message)
        rescue => e
          logger.warn(e)
        end
      else
        logger.debug("data did not catch by above #{e.class}")
      end
    rescue => e
      logger.debug(e)
    end
  end
  rescue => e
    logger.debug(e)
  end
  puts "OK"
end
