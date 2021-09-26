# frozen_string_literal: true

module GitAdder
  def self.current_git_sha
    @current_git_sha ||=
      if Rails.env.development? || Rails.env.test?
        @current_git_sha ||= `git rev-parse HEAD`
      elsif commit = ENV['HEROKU_SLUG_COMMIT']
        commit
      elsif commit = ENV['REVISION']
        commit
      else
        "unknown"
      end
  end
end
