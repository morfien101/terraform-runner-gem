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

require 'json'
class ConfigFile
  attr_reader :environment, :tf_file_path, :variable_path, :variable_files
  attr_reader :inline_variables, :state_file, :custom_args, :modules_required

  def initialize(configuration_location, logger)
    @logger = logger
    @base_dir = Dir.pwd
    convert_json_to_ruby(configuration_location)
    create_att_readers() if validate_config()
  end

  def create_att_readers()
    @environment = @config_json['environment']
    @tf_file_path = @config_json['tf_file_path']
    @variable_path = @config_json['variable_path']
    @variable_files = @config_json['variable_files']
    @inline_variables = convert_inline_var(@config_json['inline_variables'])
    @state_file = @config_json['state_file']
    @custom_args = @config_json['custom_args']
    @modules_required = @config_json['modules_required'].nil? ? false : @config_json['modules_required']
    @local_modules = @config_json['local_modules'].nil? ? { 'enabled' => false } : @config_json['local_modules']
  end

  def convert_json_to_ruby(config_file)
    # Load the configuration file specified
    # TODO Handle the JSON convert failure
    @config_json = JSON.parse(IO.read(File.join(@base_dir, config_file)))
    @logger.debug("Collected config file: #{@config_file_data}")
  end

  def file_exist(*args)
    fp = File.expand_path(File.join(@base_dir, args))
    return File.exist?(fp) ? nil : "File not found: #{fp}.\n"
  end

  def directory_exists(*args)
    fp = File.expand_path(File.join(@base_dir, args))
    return File.directory?(fp) ? nil : "Could not find directory: #{fp}.\n"
  end

  def convert_inline_var(hash)
    hash.each do |key, v|
      hash[key] = eval(v.delete('${}')) if v =~ /^\$\{ENV/ && v =~ /\}$/
    end unless hash.nil?
    return hash
  end

  def validate_config
    errors = []
    # We need to set this default value for the logic to work.
    @config_json['local_modules'] = { 'enabled' => false } if @config_json['local_modules'].nil?

    errors << required_values
    # Is the source directory there?
    @logger.debug('Is the source code dir there?')
    errors << directory_exists(@config_json['tf_file_path']) unless @config_json['tf_file_path'].nil?
    errors << directory_exists(@config_json['variable_path']) unless @config_json['variable_path'].nil?
    errors << directory_exists(@config_json['local_modules']['src_path']) if @config_json['local_modules']['enabled']

    # Is the directory and files stated in the config file available.
    errors << validate_variable_files(@config_json['variable_files']) unless @config_json['variable_files'].nil?

    if errors.flatten!.compact!.empty?
      true
    else
      EXIT.fatal_error(@logger, errors, 1)
    end
  end

  def validate_variable_files(var_files)
    errors = []
    @logger.debug('Is the variable file there?')
    var_files.each do |var_file|
      errors << file_exist(@config_json['variable_path'], var_file)
    end
    errors
  end

  def required_values
    errors = []
    # The following values are required.
    errors << err_if_nil(@config_json['tf_file_path'],
              'tf_file_path is a required value in the json file.'
              )
    errors << err_if_nil(@config_json['state_file'],
              'state_file is a required block of values in the json file.'
              )
    errors << err_if_nil(@config_json['local_modules']['src_path'],
              'local_modules - src_path is a required value when local modules is endabled.'
              ) if @config_json['local_modules']['enabled']
    errors << err_if_nil(@config_json['local_modules']['dst_path'],
              'local_modules - dst_path is a required value when local modules is endabled.'
              ) if @config_json['local_modules']['enabled']
    errors
  end

  def err_if_nil(value, message)
    message if value.nil?
  end

  private :validate_config, :directory_exists, :file_exist, :convert_json_to_ruby
  private :convert_inline_var, :required_values, :validate_variable_files, :err_if_nil
end
