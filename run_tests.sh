#!/bin/bash
EXIT_STATUS=0
docker run -v $(pwd):/usr/src/app tawan/what-happened:latest bundle exec rspec spec || EXIT_STATUS=$?
docker run -v $(pwd)/integration_tests/rails_app:/usr/src/app -v $(pwd):/usr/src/gem tawan/what-happened:rails-4-app bundle exec rspec spec || EXIT_STATUS=$?
exit $EXIT_STATUS
