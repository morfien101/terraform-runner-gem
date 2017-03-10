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

require 'logger'

class LoggerHelper
  def self.get_logger(options)
    # Setup logging
    logger = Logger.new(STDOUT)
    # Turn on debug logger if required
    logger.level = options[:debug] ? Logger::DEBUG : Logger::WARN
    logger.formatter = proc do |severity, datetime, _, msg|
      "#{severity[0]} - #{datetime}: #{msg}\n"
    end
    logger
  end
end
