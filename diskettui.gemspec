Gem::Specification.new do |spec|
  spec.name        = "diskettui"
  spec.version     = "2.0.0"
  spec.author      = "Ayush Pai"
  spec.email       = "ayushpai@ayushpai.com"
  spec.summary     = "A gem for diskettui"
  spec.homepage    = "https://ayushpai.com"

  spec.files       = Dir["{bin}/*"]
  spec.executables = ["diskettui"]

  spec.required_ruby_version = ">= 3.2.0"
end
