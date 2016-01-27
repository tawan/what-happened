# What Happened

[![Build Status](https://travis-ci.org/tawan/what-happened.svg?branch=master)](https://travis-ci.org/tawan/what-happened)


## Usage

```ruby
# config/what_happened.rb
specify do
  creating_message do
    notifies { |message| message.recipient }
  end

  updating_message do
    notifies { |message| message.recipient }
  end

  destroying_message do
    notifies { |message| message.recipient }
  end
end
```
