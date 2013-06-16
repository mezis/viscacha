require 'viscacha/version'
require 'active_support/cache'
require 'localmemcache'

module Viscacha
  class Store < ActiveSupport::Cache::Store
    DEFAULT_BACKEND_OPTIONS = {
      filename: '/tmp/viscacha.lmc',
      size_mb:  16
    }.freeze

    def initialize(options = {})
      super options
      
      backend_options = DEFAULT_BACKEND_OPTIONS.dup

      if o = options[:filename]
        backend_options[:filename] = o.to_s
      end

      if o = options[:size]
        backend_options[:size_mb] = o.to_i
      end

      @backend = LocalMemCache.new(backend_options)
    end

    def clear(options = nil)
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

    attr_reader :backend

    def read_entry(key, options = {})
      entry = backend[key]
      return nil if entry.nil?
      Marshal.load(entry)
    end

    def write_entry(key, entry, options = {}) 
      backend[key] = Marshal.dump(entry)
    end

    def delete_entry(key, options = {})
      entry = backend[key]
      backend[key] = nil
      !!entry
    end
  end
end

