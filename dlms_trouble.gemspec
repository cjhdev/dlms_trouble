spec = Gem::Specification.new do |s|
    s.name    = "dlms_trouble"
    s.version = "1.0.0"
    s.summary = "A Ruby toolkit for working with DLMS/COSEM."
    s.author  = "Cameron Harper"
    s.email = "contact@stackmechanic.com"
    s.files = Dir.glob("lib/**/*.rb") + Dir.glob("test/**/*") + ["rakefile"]
    s.license = 'MIT'
    s.test_files = Dir.glob("test/**/*.rb")
    s.required_ruby_version = 2.0
end
