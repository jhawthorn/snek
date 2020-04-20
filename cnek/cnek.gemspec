# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "cnek"
  spec.version       = "0.0.1"
  spec.authors       = ["John Hawthorn"]
  spec.email         = ["john@hawthorn.email"]

  spec.summary       = %q{C extension for battlesnake}
  spec.description   = %q{There's C in here}

  spec.files         = Dir["ext/**/*.{c,h,rb}", base: __dir__]
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/cnek/extconf.rb"]
end
