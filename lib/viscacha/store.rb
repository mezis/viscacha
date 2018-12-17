require 'viscacha/version'
require 'active_support/cache'
require 'localmemcache'

module Viscacha
  class Store < ActiveSupport::Cache::Store
    DEFAULT_DIR  = Pathname('tmp')
    DEFAULT_NAME = 'viscacha'
    DEFAULT_SIZE = 16.megabytes # also the minimum size, as localmemcache is
                                # unreliable below this value

    def initialize(options = {})
      super options
      
      directory = options.fetch(:directory, DEFAULT_DIR)
      name      = options.fetch(:name,      DEFAULT_NAME)
      size      = options.fetch(:size,      DEFAULT_SIZE)

      data_store_options = {
        filename: Pathname.new(directory).join("#{name}-data.lmc").to_s,
        size_mb:  [DEFAULT_SIZE, size].max / 1.megabyte
      }
      meta_store_options = {
        filename: Pathname.new(directory).join("#{name}-meta.lmc").to_s,
        size_mb:  data_store_options[:size_mb]
      }

      @data_store = LocalMemCache.new(data_store_options)
      @meta_store = LocalMemCache.new(meta_store_options)
    end

    def clear(options = nil)
      data_store.clear
      meta_store.clear
      self
    end

    def cleanup(options = nil)
      true
    end

    def increment(name, amount = 1, options = nil)
      raise NotImplementedError.new("#{self.class.name} does not support #{__method__}")
    end

    def decrement(name, amount = 1, options = nil)
      raise NotImplementedError.new("#{self.class.name} does not support #{__method__}")
    end

    def delete_matched(matcher, options = nil)
      raise NotImplementedError.new("#{self.class.name} does not support #{__method__}")
    end


    protected

    attr_reader :data_store, :meta_store

    def read_entry(key, options = {})
      data = data_store[key]
      meta = meta_store[key]
      return nil if data.nil? || meta.nil? || data.empty? || meta.empty?
      entry = metadata_unpack(meta, data)
      touch_entry(entry, key)
      entry
    end

    def write_entry(key, entry, options = {})
      make_space_for(entry.raw_value.bytesize)
      data_store[key] = entry.raw_value
      meta_store[key] = metadata_pack(entry)
      true
    end

    def delete_entry(key, options = {})
      meta = meta_store[key]
      data_store.delete(key)
      meta_store.delete(key)
      !(meta.nil? || meta.empty?)
    end

    def make_space_for(bytes)
      return true if get_free_space > (bytes * 2)

      keys = []
      meta_store.each_pair do |key,meta|
        keys << [key, meta.unpack('GGNC').first]
      end

      keys.sort_by(&:last).each do |key,_|
        delete_entry(key)
        return true if get_free_space > (bytes * 2) && get_free_ratio > 0.15
      end

      false
    end

    def touch_entry(entry, key)
      meta_store[key] = metadata_pack(entry, Time.now.to_f)
    end

    def get_free_space
      data_store.shm_status[:free_bytes]
    end

    def get_free_ratio
      1.0 * data_store.shm_status[:free_bytes] / data_store.shm_status[:total_bytes]
    end

    def metadata_pack(entry, used_at = nil)
      used_at ||= entry.created_at
      [used_at, entry.created_at, entry.expires_in || 0, entry.compressed? ? 1 : 0].pack('GGNC')
    end

    def metadata_unpack(meta, data)
      used_at, created_at, expires_in, compressed = meta.unpack('GGNC')

      compressed = (compressed == 1)
      expires_in = nil if expires_in == 0

      ActiveSupport::Cache::Entry.create(data, created_at, compressed: compressed, expires_in: expires_in)
    end
  end
end

