# rubot
A simple alternative to [VoltBot](https://github.com/RogueException/DiscordBot), written in Ruby. This bot receives GitHub webhooks and posts them to a Discord channel.

## How to run
You need Ruby 2.3 and Bundler. First, install all the dependencies using `bundle install`. Then create two files, "rubot-links" that contains the following:
```json
{}
```
and "rubot-auth" that contains the bot's auth token and client ID on two lines:
```
TOKEN HERE
171456123456123456
```
Then, use `ruby rubot.rb` to run it.
