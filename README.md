# RUBOT IS NOT SUPPORTED SOFTWARE

Don't come to me with whatever problem you're having while following these instructions below. They are written to be understood by anyone with a decent sense of technology and computing, and many people have succeeded in following them. If you can't, don't blame the instructions, don't blame rubot, don't blame me, blame yourself.

If you're unhappy with this, blame the flood of idiots who tried to do stupid things like host rubot on their home PC or who annoyed me with questions about server hosting. Of course, actual bug reports are welcome, but not requests for setup help.

## rubot
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

Make sure the sinatra server is open to the public (try opening "http://\<server IP\>:4567/webhook" in a browser). Once you verified that it is, add a GitHub webhook for that URL to your repo (scope should be everything) and run `rubot, link this: <user>/<repo>` in the channel you want to link the repo to. Try it out by opening a test issue.
