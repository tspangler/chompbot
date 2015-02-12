# ChompBot
### 21st century pedantry

ChompBot monitors Twitter’s streaming API for tweets that mention the (incorrect) phrase *chomping at the bit* and sends automated corrections to offenders.

## Installation
1. Clone repo.
2. `bundle install` to install dependencies.
3. [Register your app on Twitter](https://apps.twitter.com/app/new).
4. Create a `ChompBot.yml` file in the same directory as `ChompBot.rb` with your API keys and a DSN for your database:

    ```
    ---
    :consumer_key: your_consumer_key
    :consumer_secret: your_consumer_secret
    :token: your_twitter_token
    :secret: your_twitter_secret
    :db_uri: mysql://user:pass@host:port/db_name
    ```

5. Create a table called `chompbot` in your database. For MySQL, the syntax is:
    ```
    CREATE TABLE IF NOT EXISTS `chompbot` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `tweet_id` bigint(20) NOT NULL,
      `text` text NOT NULL,
      `from_user` varchar(255) NOT NULL,
      `from_user_id` varchar(255) NOT NULL,
      `city` varchar(255) NOT NULL,
      `country` varchar(255) NOT NULL,
      `lat` decimal(9,6) DEFAULT NULL,
      `lng` decimal(9,6) DEFAULT NULL,
      `tweet_json` text NOT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    ```

6. `ruby ChompBot.rb`

If all goes well, ChompBot will start up, connect to the streaming API and begin listening.

### Running in the background
If you’re running ChompBot on a remote server, your process will be killed as soon as you log out. To prevent this, I suggest running in a `screen` session:

1. `screen -S chompbot`
2. `ruby ChompBot.rb`
3. Ctrl+A > Ctrl+D

You may now log out of your shell, and ChompBot will continue running. To get back to it, login again and run `screen -r chompbot`.

## About
ChompBot was created by [@symsonic](https://twitter.com/symsonic), who went to [journalism school](http://www.medill.northwestern.edu) and learned the glory of AP style under the instruction of the unparalleled [@mpacatte](https://twitter.com/mpacatte). Its mission is to spread awareness of proper style, and probably receive a lot of angry @replies in the process.