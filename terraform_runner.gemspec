# coding: utf-8
# Copyright 2017 Randy Coburn
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'src/version'

Gem::Specification.new do |spec|
  spec.name          = 'terraform_runner'
  spec.version       = TerraformRunner::VERSION
  spec.authors       = ['Randy Coburn']
  spec.email         = ['morfien101@gmail.com']

  spec.summary       = 'This gem allows you to wrap Hashi Corps Terraform in to a repeatable process.'
  spec.description   = 'More documentation can be found on https://github.com/morfien101/terraform-runner}'
  spec.homepage      = 'https://github.com/morfien101/terraform-runner'
  spec.license       = 'Apache-2.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to "http://mygemserver.com"'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = Dir['{lib}/**/*', 'README*', 'LICENSE*']
  spec.require_paths = ['lib']
end
