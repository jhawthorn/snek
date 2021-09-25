mkdir -p /data
export DATABASE_URL=sqlite3:/data/db.sqlite3
bundle exec rake db:migrate
bundle exec rails server -b 0.0.0.0 -p 3000
