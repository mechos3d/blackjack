module Persistence

  class CookiePersistence
    def self.storage=(session)
      @@storage = session
    end

    def self.storage
      @@storage
    end
  end

  def set_value(key, value)
    storage[key] = prepare(value)
  end

  def get_value(key)
    return nil unless storage[key]
    JSON.parse(storage[key])
  rescue JSON::ParserError
    storage[key]
  end

  def set_values(values_hash)
    values_hash.each_pair do |key, value|
      storage[key] = prepare(value)
    end
  end

  private

  def storage
    CookiePersistence.storage
  end

  def prepare(value)
    if value.is_a?(Numeric) || value.is_a?(String)
      value.to_s
    else
      value.to_json
    end
  end
end
