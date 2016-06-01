spec = Gem::Specification.new do |s|
    s.name    = "dlms_trouble"
    s.version = "1.0.0"
    s.summary = "A Ruby toolkit for working with DLMS/COSEM."
    s.author  = "Cameron Harper"
    s.files = Dir.glob("lib/**/*.rb") + Dir.glob("test/**/*") + ["rakefile"]
    s.license = 'MIT'
    s.test_files = Dir.glob("test/**/*.rb")    
end
