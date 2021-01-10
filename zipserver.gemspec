Gem::Specification.new do |s|
  s.name = %q{zipserver}
  s.version = "0.0.2"
  s.authors = ["Jo Ago"]
  s.date = %q{2021-01-07}
  s.summary = %q{Web Server}
  s.require_paths = ["lib"]

  s.files =`git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|docker)/}) }
  s.add_development_dependency "rack"
end

