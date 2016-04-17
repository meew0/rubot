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

## How to use

Make sure the sinatra server is open to the public (try opening "http://<server IP>:4567/webhook" in a browser). Once you verified that it is, add a GitHub webhook for that URL to your repo (scope should be everything) and run `rubot, link this: <user>/<repo>` in the channel you want to link the repo to. Try it out by opening a test issue.
