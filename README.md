# Logstash Plugin

his is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Add to your logstash configuration file:
```ruby
output {
    kontur_elk {
        # The index to write events to. This can be dynamic using the %{foo} syntax.
        index => ... # string (required)
        # Hostname of RabbitMQ server
        rabbitmq_host => ... # string (required)
        # Port of RabbitMQ server
        rabbitmq_port => ... # number (optional), default: 5672
        # RabbitMQ user
        user => ... # string (required)
        # RabbitMQ password
        password => ... # string (reqiured)
        # RabbitMQ Queue
        queue => ...  # string (reqiured)
    }
}
```
## Requires 
- Logstash version 1.5.x
- Work on jruby only

## Installation
```
wget https://github.com/skbkontur/logstash-output-kontur_elk/raw/master/logstash-output-kontur_elk-0.0.9.gem
bin/plugin install logstash-output-kontur_elk-0.0.9.gem
```
or
```
git clone https://github.com/skbkontur/logstash-output-kontur_elk.git
gem build logstash-output-kontur_elk.gemspec
bin/plugin install logstash-output-kontur_elk-0.0.9.gem
```
