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

require 'optparse'
# Gather the options
class Options
  def self.get_options(arguments)
    options = default_options
    OptionParser.new do |opts|
      banner_seperator(opts)
      config(opts, options)
      actions(opts, options)
      custom_parameter(opts, options)
      modules(opts, options)
      prompts(opts, options)
      json_example(opts)
      help(opts)
      version(opts)
      debug(opts, options)
    end.parse!(arguments)

    options
  end

  def self.default_options
    {
      silent: false,
      action: 'plan',
      debug: false,
      create_json: false,
      module_updates: false
    }
  end

  def self.banner_seperator(opts)
    opts.banner = 'Usage: terraform-runner.rb [options]'
    opts.separator ''
    opts.separator 'Specific options:'
  end

  def self.config(opts, options)
    # Get the options flags
    opts.on('-c', '--config-file /path/to/file', String, 'Path to config JSON file') do |config|
      options[:config_file] = config.strip
    end
  end

  def self.actions(opts, options)
    opts.on('-a', '--action action_type', String, "Terraform action: #{CommandBuilder::VALID_ACTIONS.join(', ')}") do |action|
      # Validate the actions here ...
      options[:action] = action
    end
  end

  def self.modules(opts, options)
    opts.on('--update-modules', 'Forces updates of modules. Only to be used with the get action.') do
      options[:module_updates] = true
    end
  end

  def self.custom_parameter(opts, options)
    opts.on('-p', '--custom-parameters ARGS', String, 'Parameters that will be added as is to the Terraform run.',
            'Presented as a comma sperated string "-arg1,-arg2"') do |s|
      options[:custom_parameter] = s.respond_to?(:gsub) ? s.gsub(/ |\"/, '').split(',') : 'custom_parameter_failed'
    end
  end

  def self.prompts(opts, options)
    opts.on('-f', '--force', 'No prompts') do
      options[:silent] = true
    end
  end

  def self.help(opts)
    opts.on('-h', '--help', 'Displays this screen') do
      puts opts
      exit 0
    end
  end

  def self.version(opts)
    opts.on('-v', '--version', 'Display the version') do
      puts TerraformRunner::VERSION
      exit 0
    end
  end

  def self.debug(opts, options)
    opts.on('--debug') do
      options[:debug] = true
    end
  end

  def self.json_example(opts)
    json_code = <<-EOF
{
  "environment": "Running Environment",
  "tf_file_path":"path/",
  "variable_path":"path/",
  "variable_files":["vars1.tfvars","vars2.tfvars"],
  "inline_variables":{
    "aws_ssh_key_path":"${ENV[\'AWS_SSH_KEY_PATH\']}",
    "aws_ssh_key_name": "myawskey"
  },
  "state_file":{
    "type":"s3",
    "config": {
      "region":"eu-west-1",
      "bucket":"terraform-bucket",
      "key":"path/to/terraform-state.tfstate"
    }
  },
  "modules_requried": false,
  "custom_args":["-parallelism=10"]
}
EOF

    opts.on('--json-example', 'Prints default JSON file.') do
      puts json_code
      exit 0
    end
  end
end
