module Persistence

  class Namespace
    @@value

    def self.value=(value)
      @@value = value
    end

    def self.value
      @@value
    end
  end

  def set_value(key, value)
    redis.set(namespaced(key), prepare(value))
  end

  def get_value(key)
    key = namespaced(key)
    return nil unless redis.get(key)
    JSON.parse(redis.get(key))
  rescue JSON::ParserError
    redis.get(key)
  end

  def set_values(values_hash)
    redis.pipelined do
      values_hash.each_pair do |key, value|
        redis.set(namespaced(key), prepare(value))
      end
    end
  end

  private

  def namespaced(key)
    "#{ Namespace.value }_#{ key }"
  end

  def prepare(value)
    if value.is_a?(Numeric) || value.is_a?(String)
      value.to_s
    else
      value.to_json
    end
  end

  def redis
    @redis ||=
      if ENV['RACK_ENV'] == 'test'
        MockRedis.new
      else
        Redis.new
      end
  end
end
