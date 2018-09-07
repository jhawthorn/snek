# starter-snake-ruby

A simple [Battlesnake AI](http://battlesnake.io) written in Ruby with [Sinatra](http://www.sinatrarb.com/).

This is loosely based on Heroku's official [Getting Started with Ruby App](https://github.com/heroku/ruby-getting-started).

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

### App Overview

- `web.rb` is where the three actions must be implemented: `start`, `move`, `end`

- Each handler is already set up to parse and render JSON.

### Setup and Installation


#### 1. Install Ruby

These steps assume you've installed ruby locally. If you haven't, a good Ruby version manager is [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://github.com/asdf-vm/asdf) with [asdf ruby](https://github.com/asdf-vm/asdf-ruby). 

If you're opting for rbenv, this might be handy: [Install Ruby](https://jasoncharnes.com/install-ruby)


#### 2. Fork and clone this repo:

```
git clone https://github.com/sendwithus/battlesnake-ruby.git
cd battlesnake-ruby
```

#### 3. Install [Bundler](https://bundler.io/):

```
gem install bundler
```

#### 4. Install dependencies:

```
bundle install
```

#### 5. Run the server:

```
foreman start web
```

Test the client in your browser: [http://localhost:5000](http://localhost:5000)


### Deploying to Heroku

Click the Deploy to Heroku button at the top or use the command line commands below.

Create a new Heroku app:

```
heroku apps:create APP_NAME
```

Push code to Heroku servers:

```
git push heroku master
```

Open Heroku app in browser:

```
heroku open
```

Or go directly via http://APP_NAME.herokuapp.com

View/stream server logs:

```
heroku logs --tail
```
