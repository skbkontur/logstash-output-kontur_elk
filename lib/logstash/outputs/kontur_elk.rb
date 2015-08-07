# encoding: utf-8
require "logstash/namespace"
require "logstash/outputs/base"
require "json"

class LogStash::Outputs::KonturElk < LogStash::Outputs::Base

  config_name "kontur_elk"

  # The index to write events to. This can be dynamic using the %{foo} syntax.
  config :index, :validate => :string, :required => true

  # The index type to write events to. Generally you should try to write only
  # similar events to the same 'type'. String expansion '%{foo}' works here.
  config :index_type, :validate => :string, :default => "%{type}"

  # Hostname of RabbitMQ server
  config :rabbitmq_host, :validate => :string, :required => true

  # Port of RabbitMQ server
  config :rabbitmq_port, :validate => :number, :default => 5672

  # RabbitMQ user
  config :user, :validate => :string, :required => true

  # RabbitMQ password
  config :password, :validate => :string, :required => true

  # RabbitMQ Queue
  config :queue, :validate => :string, :required => true

  # Enable or disable SSL
  config :ssl, :validate => :boolean, :default => false

  # Validate SSL certificate
  config :verify_ssl, :validate => :boolean, :default => false

  public
  def register
    require "march_hare"
    require "java"

    @logger.info("Registering output", :plugin => self)
    @initialized = java.util.concurrent.atomic.AtomicBoolean.new
  end

  public
  def receive(event)
    return unless output?(event)
    max_field_size = 10922
    begin
      if connect
        new_event = Hash.new
        event.to_hash.each do | key, value |
          if value.class == String 
            if value.length > max_field_size
               truncated = value.length - max_field_size
               truncated_label = "truncated #{truncated}"
               value = value[0, max_field_size - truncated_label.length - 3] + "[#{truncated_label}]"
               new_event["@truncated"] = truncated_label
            end
          end
          new_event[key] = value
        end
        header = { "index" => { "_index" => event.sprintf(@index), "_type" => event.sprintf(@index_type) } }
        @exchange.publish(header.to_json + "\n" + new_event.to_json + "\n", :routing_key => @queue, :properties => { :persistent => false })
      end
    rescue MarchHare::Exception, IOError, com.rabbitmq.client.AlreadyClosedException => e
      @logger.error("RabbitMQ connection error: #{e.message}. Will attempt to reconnect in 10 seconds...", :exception => e, :backtrace => e.backtrace)
      sleep 10
      retry
    end
  end

  private 
  def connect

    while @connection && !@connection.open? do 
      @logger.warn("Waiting for connection at #{@rabbitmq_host}")
      sleep 10
    end

    return true if @initialized.get
    return true if not @initialized.compareAndSet(false, true)
 
    @settings = {
      :vhost => "/",
      :host  => @rabbitmq_host,
      :port  => @rabbitmq_port,
      :user  => @user,
      :pass  => @password,
      :tls   => @ssl,
      :automatic_recovery => true
    }

    begin
      @connection = MarchHare.connect(@settings)
      @channel = @connection.create_channel
      @logger.info("Connected to RabbitMQ at #{@settings[:host]}")
      @logger.debug("Declaring an exchange", :name => @queue, :type => :direct, :durable => true)
      @exchange = @channel.exchange(@queue, :type => :direct, :durable => true)
    rescue MarchHare::Exception => e
      @logger.error("RabbitMQ connection error: #{e.message}. Will attempt to reconnect in 10 seconds...", :exception => e, :backtrace => e.backtrace)
      sleep 10
      retry
    end

    return true
  end
end
