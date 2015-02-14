#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'
require 'colorize'
require 'active_support'
require 'active_support/core_ext'

# debug_mode
verbose

# Check for database
if !db.tables.include?(:chompbot)
  puts "#{'Chompbot database not found'.colorize(:red)}. Please create it first."
  exit
end

puts "Starting #{'ChompBot'.colorize(:light_cyan)} using the streaming API..."

streaming do
  search "chomping at the bit" do |tweet|
    # Have we corrected this user in the last two hours?
    if (tweet.created_at < 2.hours.ago) && !tweet.retweet?
      responses = [
        '#USER# The correct term is "champing."',
        '#USER# I believe you meant "champing."',
        '#USER# Did you know that the term is actually "champing at the bit?"',
        '#USER# I think you meant to say "champing at the bit."',
        '#USER# FYI, I think you wanted "champing" at the bit.',
        '#USER# It\'s actually "champing," not "chomping."'
      ]

      # Have we corrected this user in the last hour?
      this_user = tweet.user.id

      # Fave everybody we correct
      begin
        favorite tweet
      rescue Exception => e
        puts "{'Could not favorite tweet.'.colorize(:red)}"
        puts 'Exception:'.colorize(:red) + ' ' + e.message
      end


      # Pick a response at random and append the link
      begin
        reply responses.sample + ' http://chompbot.herokuapp.com', tweet
      rescue Exception => e
        puts "{'Could not reply to tweet.'.colorize(:red)}"
        puts 'Exception:'.colorize(:red) + ' ' + e.message
      end

      # Log it
      data = {}
    
      data['tweet_id'] = tweet.id
      data['text'] = tweet.text
      data['from_user'] = tweet.user.username
      data['from_user_id'] = tweet.user.id
      data['created_at'] = tweet.created_at
    
      # Serialize the entire tweet for the hell of it
      data['tweet_json'] = tweet.to_h.to_json

      # Look for coordinates; add if we have them
      if tweet.geo.coordinates
        data['lat'] = tweet.geo.coordinates[0].nil? ? '' : tweet.geo.coordinates[0] 
        data['lng'] = tweet.geo.coordinates[1].nil? ? '' : tweet.geo.coordinates[1]
      end

      # Add a city if we have one
      if tweet.place
        if tweet.place.place_type == 'city'
          data['city'] = tweet.place.full_name.nil? ? '' : tweet.place.full_name
        end
      
        data['country'] = tweet.place.country_code.nil? ? '' : tweet.place.country_code
      end    

      db[:chompbot].insert(data)
    else
      puts 'Not correcting user: too soon since last correction or tweet is a retweet'
    end    
  end
end