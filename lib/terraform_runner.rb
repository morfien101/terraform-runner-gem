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

# Bring in our source files
require_relative 'src/modules_lib'
require_relative 'src/logger_lib'
require_relative 'src/options_lib'
require_relative 'src/input_checker'
require_relative 'src/command_builder_lib'
require_relative 'src/command_lib'
require_relative 'src/config_file_lib'
require_relative 'src/terraform_lib'

# The version of the program is in here.
require_relative 'src/version'

require 'fileutils'
require 'time'
