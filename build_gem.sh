#!/bin/bash
if [[ $(sudo /usr/local/bin/rspec $(pwd)) ]]; then
  sudo /usr/bin/gem build $(pwd)/terraform_runner.gemspec
else
  echo "rspec tests have failed."
fi

