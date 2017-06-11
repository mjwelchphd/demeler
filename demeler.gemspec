require_relative File.dirname(__FILE__) + '/lib/demeler/version'
include Version
Gem::Specification.new do |s|
  s.author        = "Michael J. Welch, Ph.D."
  s.files         = Dir.glob(["CHANGELOG.md", "LICENSE.md", "README.md", "demeler.gemspec", "lib/*", "lib/demeler/*", "notes", "spec/*", ".gitignore"])
  s.name          = 'demeler'
  s.require_paths = ["lib"]
  s.summary       = 'Yet another HTML generator.'
  s.version       = VERSION
  s.date          = MODIFIED
  s.email         = 'mjwelchphd@gmail.com'
  s.homepage      = 'http://rubygems.org/gems/demeler'
  s.license       = 'MIT'
  s.description   = "This gem takes your ruby input, plus an object such as a Sequel::Model object, and generates HTML code. If the object has values, they're inserted into the HTML, and if the object has error messages, code is generated to display them. You can use CSS, but it's not automated in this class of methods."
end
