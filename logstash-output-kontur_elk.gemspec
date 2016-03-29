Gem::Specification.new do |s|
  s.name = 'logstash-output-kontur_elk'
  s.version         = "0.1.1"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "SKB Kontur custom RabbitMQ output plugin"
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Elastic"]
  s.email = "devops@skbkontur.ru"
  s.homepage = "https://github.com/skbkontur/logstash-output-kontur_elk"
  s.require_paths = ["lib"]

  # Files
  s.files = ["Gemfile", "LICENSE", "README.md", "Rakefile", "lib/logstash/outputs/kontur_elk.rb", "logstash-output-kontur_elk.gemspec"]
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_development_dependency "logstash-devutils"
end
