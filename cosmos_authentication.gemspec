# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cosmos_authentication/version"

Gem::Specification.new do |s|
  s.name        = "cosmos_authentication"
  s.version     = CosmosAuthentication::VERSION
  s.authors     = ["Sebastian Edwards"]
  s.email       = ["sebastian@uprise.co.nz"]
  s.homepage    = "https://github.com/SebastianEdwards/cosmos_authentication"
  s.summary     = %q{A client for the cosmos authentication service.}
  s.description = s.summary

  s.rubyforge_project = "cosmos_authentication"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "cosmos"
end
