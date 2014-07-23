require_relative 'connection'

module Nsq
  class Consumer

    attr_reader :host
    attr_reader :port
    attr_reader :topic
    attr_reader :messages

    # We include Celluloid for its finalizer logic - consider removing
    include Celluloid
    finalizer :on_terminate

    def initialize(opts = {})
      @host = opts[:host] || '127.0.0.1'
      @port = opts[:port] || 4150
      @topic = opts[:topic] || raise(ArgumentError, 'topic is required')
      @channel = opts[:channel] || raise(ArgumentError, 'channel is required')

      @messages = Queue.new

      @connection = Connection.new(@host, @port)

      # subscribe and set ready
      @connection.sub(@topic, @channel)
      @connection.rdy(10)

      # listen for messages
      @connection.async.listen_for_messages(@messages)
    end


    private
    def on_terminate
      @connection.async.stop_listening_for_messages
    end
  end
end
