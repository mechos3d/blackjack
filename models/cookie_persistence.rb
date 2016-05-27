class CookiePersistence
  def self.storage=(session)
    @@storage = session
  end

  def self.storage
    @@storage
  end
end