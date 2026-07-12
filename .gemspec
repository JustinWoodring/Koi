Gem::Specification.new do |s|
  s.name        = 'koi-server'
  s.version     = '1.0.0'
  s.licenses    = ['MIT']
  s.summary     = "Koi is a ruby-based Gemini server that supports ERB templating."
  s.description = "Koi is a ruby-based Gemini server that supports .erb templating, and static files, and handles TLS certs for you.

Koi is designed to make hosting Gemini CGI pages a joyful and
tranquil experience, uniting the conceptual beauty of a simple web
with developer happiness.

By using a combination of Ruby powered ERB templating and
traditional static file serving we distill a solution offering
the best of both worlds.
"
  s.authors     = ["Justin Woodring"]
  s.email       = 'jwoodrg@gmail.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.executables << "koi"
  s.homepage    = 'https://rubygems.org/gems/koi'
  s.metadata    = { "source_code_uri" => "https://github.com/JustinWoodring/Koi" }
end
