Gem::Specification.new do |s|
  s.name = %q{cinder}
  s.version = "0.4.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Bueti", "Matt Pelletier"]
  s.date = %q{2008-06-17}
  s.description = %q{Cinder is a Ruby library for exporting transcripts from Campfire into CSV files.}
  s.email = %q{matt@eastmedia.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "lib/cinder.rb", "lib/cinder/campfire.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/eastmedia/cinder}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cinder}
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{Export Campfire transcripts into CSVs}

  s.add_dependency(%q<mechanize>, [">= 0"])
  s.add_dependency(%q<colored>, [">= 0"])
  s.add_dependency(%q<hoe>, [">= 1.5.3"])
end
