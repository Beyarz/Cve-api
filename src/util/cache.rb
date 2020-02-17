# typed: strict
# frozen_string_literal: true

require 'psych'

# Cache utility
class Cache
  # Get cache for key
  def self.get_by(key)
    # Check if cache exists
    return nil unless File.exist?("cache/#{key}")

    # Read cache
    raw = File.read("cache/#{key}")
    content = Psych.safe_load(raw, permitted_classes: [Symbol, Time])

    # Invalidate cache if it has become stale
    if content['expires'] < Time.now
      remove_by(key)
      return nil
    end

    return content['value']
  end

  # Remove cache
  def self.remove_by(key)
    File.delete("cache/#{key}")
  end

  # Add cache
  def self.add(key, value, ttl)
    content =
      {
        'key' => key,
        'value' => value,
        'expires' => Time.now + ttl.to_i
      }
    file = File.open("cache/#{key}", 'w+')
    file.write(content.to_yaml)
    file.close
  end
end
