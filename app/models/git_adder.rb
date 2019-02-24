module GitAdder
  def self.current_git_sha
    @current_git_sha ||=
      if Rails.env.development? || Rails.env.test?
        @current_git_sha ||= `git rev-parse HEAD`
      else
        ENV['HEROKU_SLUG_COMMIT']
      end
  end
end
