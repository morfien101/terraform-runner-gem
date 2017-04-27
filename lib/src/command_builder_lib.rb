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

class CommandBuilder
  VALID_ACTIONS = %w(plan apply destroy get output).freeze

  def initialize(options, config_file, logger)
    @action = options[:action]
    @module_updates = options[:module_updates]
    @custom_parameter = options[:custom_parameter].nil? ? [] : options[:custom_parameter]
    @base_dir = Dir.pwd
    @config_file = config_file
    @logger = logger
  end

  # Gives us the location of the terraform bin file based on the running OS
  def terraform_bin
    OS.locate('terraform')
  end

  def escape_values(w)
    return %("#{w}") if w.respond_to?(:include?) && w.include?(' ')
    return w
  end

  def digest_inline_vars(vars)
    vars.map do |k, v|
      # TODO: move expanding ENV variables to the ConfigFile class
      if v =~ /^\$\{ENV/
        vraw = v
        v = eval(v.delete('${}'))
        logger.warn("#{vraw} does not have a value.") if v.nil?
      end
      "-var #{k}=#{escape_values(v)}" unless v.nil?
    end.join(' ') unless vars.nil? || vars.empty?
  end

  def digest_var_files(path, files)
    files.map do |file|
      "-var-file=\"#{File.join(@base_dir, path, file)}\""
    end.join(' ') unless files.nil? || files.empty?
  end

  def digest_custom_args(args)
    args.join(' ') unless args.nil?
  end

  def join_text(array)
    array.join(' ').rstrip
  end

  def action_builder_selector(action)
    case action
    when 'plan'
      return make_terraform_plan
    when 'apply'
      return make_terraform_apply
    when 'destroy'
      return make_terraform_destroy
    when 'get'
      return make_terraform_get
    when 'output'
      return make_terraform_output
    end
  end

  def command_flag_digester
    retval = []
    retval << digest_inline_vars(@config_file.inline_variables)
    retval << digest_var_files(@config_file.variable_path, @config_file.variable_files)
    retval << digest_custom_args(@config_file.custom_args)
    retval
  end

  def make_terraform_plan
    retval = ['plan']
    retval << command_flag_digester
    retval << '-detailed-exitcode'
    retval
  end

  def make_terraform_apply
    retval = ['apply']
    retval << command_flag_digester
  end

  def make_terraform_destroy
    retval = ['destroy']
    retval << command_flag_digester
    retval << '-force'
    retval
  end

  def make_terraform_get
    retval = ['get']
    retval << '-update' if @module_updates
    retval
  end

  def make_terraform_output
    'output'
  end

  def add_custom_parameters
    join_text @custom_parameter unless @custom_parameter.empty?
  end


  def tf_action_cmd
    tf_action_command = []
    tf_action_command << terraform_bin
    tf_action_command << action_builder_selector(@action)
    tf_action_command << add_custom_parameters
    return join_text tf_action_command
  end

  def tf_state_file_cmd
    tf_state_file_command = "#{terraform_bin} init"
    #tf_state_file_command = "#{terraform_bin} remote config -backend=#{@config_file.state_file['type']}"
    #@config_file.state_file['config'].each do |k, v|
    #  tf_state_file_command += " -backend-config=\"#{k}=#{v}\""
    #end
    return tf_state_file_command
  end

  def tf_module_get_cmd
    join_text [terraform_bin, make_terraform_get]
  end

  private :join_text, :digest_inline_vars, :digest_var_files, :digest_custom_args
  private :terraform_bin, :escape_values
  private :make_terraform_plan, :make_terraform_apply, :make_terraform_destroy, :make_terraform_get, :make_terraform_output
end
