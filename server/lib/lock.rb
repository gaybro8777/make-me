module PrintMe
  class Lock
    attr_reader :file

    def initialize(file)
      @file = file
    end

    ## High level API
    def locked?
      lock_key(:status, :unknown).to_sym == :locked
    end

    def lock!
      update_lock :status => :locked
    end

    def unlock!
      update_lock :status => :unlocked
    end

    ## I/O API
    def update_lock(h={})
      current = (read_lock || {}).merge h
      File.open(@file, 'w') do |f|
        Yajl::Encoder.encode(h, f)
      end
    end

    def read_lock(default=nil)
      File.exist?(@file) && File.open(@file) do |f|
        Yajl::Parser.new(:symbolize_keys => true).parse f
      end || default
    end

private
    def lock_key(key, default=nil)
      read_lock({}).fetch(key.to_sym, default)
    end
  end
end
