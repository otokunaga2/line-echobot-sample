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
#post handler
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
      if event.is_a?(Line::Bot::Event::Message)
        begin
          reply_token = event['replyToken'] if event['replyToken']  
        rescue => e
          logger.warn("while event setting error has occured")
        end
        reply_message_text = event['message']['text'] if event['message']['text']

        logger.debug("data comes here")
        message = {}

        logger.debug("event data is set as #{event['message']['text']}")
        begin
        message = {
          type: 'text',
          #text: reply_message_text
          text:  "hogehoge"
        }
        rescue => e
          logger.warn(e)
        end
        begin
          logger.debug("reply message_test1 #{reply_token}, #{message}")
          response = client.reply_message(reply_token, message)
          #response = client.push_message("5234458995507", message)

          logger.debug("post reply message #{client}")
          logger.debug("response =#{response}")
        rescue => e
          logger.warn(e)
        end
      else
        logger.debug("data did not catch by above #{event['type'].class}")
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
