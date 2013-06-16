require 'viscacha/version'
require 'active_support/cache'
require 'localmemcache'

module Viscacha
  class Store < ActiveSupport::Cache::Store
    DEFAULT_DIR  = Pathname('/tmp')
    DEFAULT_NAME = 'viscacha'
    DEFAULT_SIZE = 16.megabytes

    def initialize(options = {})
      super options
      
      directory = options.fetch(:directory, DEFAULT_DIR)
      name      = options.fetch(:name,      DEFAULT_NAME)
      size      = options.fetch(:size,      DEFAULT_SIZE)

      data_store_options = {
        filename: Pathname.new(directory).join("#{name}-data.lmc").to_s,
        size_mb:  size / 1.megabyte
      }
      meta_store_options = {
        filename: Pathname.new(directory).join("#{name}-meta.lmc").to_s,
        size_mb:  data_store_options[:size_mb]
      }

      @data_store = LocalMemCache.new(data_store_options)
      @meta_store = LocalMemCache.new(meta_store_options)
    end

    def close
      @data_store.close
      @meta_store.close
    end

    def clear(options = nil)
      data_store.keys.each { |k| data_store[k] = nil }
      meta_store.keys.each { |k| meta_store[k] = nil }
    end

    def prune(options = nil)
    end

    def cleanup(options = nil)
    end

    def increment(name, amount = 1, options = nil)
    end

    def decrement(name, amount = 1, options = nil)
    end

    def delete_matched(matcher, options = nil)
    end

    protected

    attr_reader :data_store, :meta_store

    def read_entry(key, options = {})
      data = data_store[key]
      meta = meta_store[key]
      return nil if data.nil? || meta.nil? || data.empty? || meta.empty?
      metadata_unpack(meta, data)
    end

    def write_entry(key, entry, options = {}) 
      data_store[key] = entry.raw_value
      meta_store[key] = metadata_pack(entry)
    end

    def delete_entry(key, options = {})
      data = data_store[key]
      data_store[key] = nil
      meta_store[key] = nil
      !(data.nil? || data.empty?)
    end

    # 
    def make_space_for(bytes)
      # FIXME
    end

    # 
    def touch_entry(entry)
    end

    # 
    def get_free_space
      data_store.shm_status[:free_bytes]
    end

    def metadata_pack(entry)
      [entry.created_at, entry.created_at, entry.expires_in || 0, entry.compressed? ? 1 : 0].pack('GGNC')
    end

    def metadata_unpack(meta, data)
      used_at, created_at, expires_in, compressed = meta.unpack('GGNC')

      compressed = (compressed == 1)
      expires_in = nil if expires_in == 0

      ActiveSupport::Cache::Entry.create(data, created_at, compressed:compressed, expires_in:expires_in)
    end
  end
end

