# попробовать закинуть Редис в константу или глобальную переменную -
# тогда его из тестов проще будет флашить
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

  def set_values(values_hash)
    redis.pipelined do
      values_hash.each_pair do |key, value|
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
    @redis ||=
      if ENV['RACK_ENV'] == 'test'
        MockRedis.new
      else
        Redis.new
      end
  end
end
