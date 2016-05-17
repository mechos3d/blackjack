module RedisPersistence
  def set_value(key, value)
    redis.set(key, prepare(value))
  end

  def get_value(key)
    return nil unless redis.get(key)
    JSON.parse(redis.get(key))
  rescue JSON::ParserError
    redis.get(key)
  end

  def set_values(key_values_hash)
    redis.pipelined do
      key_values_hash.each_pair do |key, value|
        redis.set(key, prepare(value))
      end
    end
  end

  private

  def prepare(value)
    if value.is_a?(Numeric) || value.is_a?(String)
      value.to_s
    else
      value.to_json
    end
  end

  def redis
    @redis ||= Redis.new
  end
end
