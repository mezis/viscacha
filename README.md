<h1 style='line-height:1'>
Viscacha —<br/>
a fast shared memory cache for Rails apps.
</h1>

[![Gem Version](https://badge.fury.io/rb/viscacha.png)](http://badge.fury.io/rb/viscacha)
[![Build Status](https://travis-ci.org/mezis/viscacha.png?branch=master)](https://travis-ci.org/mezis/viscacha)
[![Dependency Status](https://gemnasium.com/mezis/viscacha.png)](https://gemnasium.com/mezis/viscacha)
[![Code Climate](https://codeclimate.com/github/mezis/viscacha.png)](https://codeclimate.com/github/mezis/viscacha)
[![Coverage Status](https://coveralls.io/repos/mezis/viscacha/badge.png)](https://coveralls.io/r/mezis/viscacha)

**TL;DR**: If you have more workers per machine than machines total, Viscacha may be much more efficient than Memcache. Of course YMMV.

Reads and writes to Viscacha will always be between 10 and **50 times faster than to a Memcache server**.

### Use cases

If you run an app on few machines with multiple workers, typical for feldging apps hosted on Heroku, you're may already be using Memcache to store fragments and the odd flag.

The roundtrip to Memcache servers is expensive (3-5ms per `fetch` is typical), so it's not much of an advantage over in-memory caching… except you can't afford the memory for a large cache on each worker.

Viscacha lets you run an in-process cache that's almost as fast as `ActiveSupport::MemoryStore`, but

- shared between processes on the same machine (or dyno)
- persistent (to the extent that the machine keeps files—Heroku will of course not persist your cache across dyno restarts)
- memory mapped (so it doesn't hijack your low dyno resources)

It's not shared across *machines* like Memcache is (it's not a server) but for high worker-per-machine to machine ratio (e.g. 2:2, or 4 workers spread over 2 machines), it's really worth it.

For bigger apps running on few machines (e.g. 12:4 on Amazon's 8-core instances), it's even more efficient, as your cache will effectively be shared by more workers.

### How it works

Viscacha is a fairly thin wrapper around []localmemcache](http://localmemcache.rubyforge.org).


## Installation

Add this line to your application's Gemfile:

    gem 'viscacha'

And then execute:

    $ bundle
    
If using Rails, in `config/application.rb`:

    config.cache_store = :viscacha
    
Done!


## Usage

Use as you'd usually use any other ActiveSupport [cache backend](http://apidock.com/rails/ActiveSupport/Cache/Store), the
excellent [Dalli](https://github.com/mperham/dalli) for instance.

**CAVEAT**: by design, calling `#clear` on a Viscacha cache (e.g. through `Rails.cache.clear`), or any other write operation (`#delete`, `#write`), will not propagate to workers on other machines!

Be careful to only use `#fetch`, and design accordingly: no cache sweepers, rely on timestamps, IDs, and expiry instead.


## Benchmarks

Bear in mind those are microbenchmarks, so your mileage may vary. The bottom
line is that on a single machine, Viscacha will be considerably faster than Memcache in pretty much all situations.

This compares how 5 cache stores react to repeated `#fetch` calls, using modern hardware and networking (2.2GHz Core i7, running Darwin).

- Viscacha
- `ActiveSupport::MemMacheStore` (using the `memcache-client`)
- `ActiveSupport::DalliStore` (using the `dalli` gem)
- `ActiveSupport::DalliStore` running off another machine (local, 1GBps copper connection)
- `ActiveSupport::MemoryStore` for reference

in 3 situations

- 100% miss: the key is statistically never present in the cache
- 100% hit: the key is always present in the cache
- 50% hit: the key is statistically present in the cache every other call

with two types of data:

30 bytes data (could be a set of flags, numbers, a small serialized object):

    viscacha 100% miss    24630.2 (±30.4%) i/s
    viscacha 100%  hit    28908.7 (±32.8%) i/s
    viscacha  50%  hit    23857.8 (±30.9%) i/s
    memcache 100% miss      849.8 (±8.1%)  i/s
    memcache 100%  hit     1667.7 (±11.4%) i/s
    memcache  50%  hit      884.8 (±9.5%)  i/s
       dalli 100% miss     4526.7 (±28.5%) i/s
       dalli 100%  hit     8239.3 (±28.2%) i/s
       dalli  50%  hit     4348.7 (±27.9%) i/s
     dalli_r 100% miss      363.7 (±13.2%) i/s
     dalli_r 100%  hit      807.8 (±12.1%) i/s
     dalli_r  50%  hit      375.6 (±12.8%) i/s
      memory 100% miss    23129.6 (±46.2%) i/s
      memory 100%  hit    39914.2 (±64.3%) i/s
      memory  50%  hit    22500.3 (±59.8%) i/s

25kb data (a fairly large HTML fragment for instance):

    viscacha 100% miss    10168.0 (±9.9%)  i/s
    viscacha 100%  hit    13131.1 (±9.9%)  i/s
    viscacha  50%  hit    10799.0 (±7.1%)  i/s
    memcache 100% miss     2163.7 (±7.9%)  i/s
    memcache 100%  hit     5179.7 (±3.5%)  i/s
    memcache  50%  hit     2315.1 (±7.0%)  i/s
       dalli 100% miss     3789.7 (±3.7%)  i/s
       dalli 100%  hit     9539.2 (±8.8%)  i/s
       dalli  50%  hit     4222.7 (±5.4%)  i/s
     dalli_r 100% miss      253.7 (±4.7%)  i/s
     dalli_r 100%  hit      855.3 (±2.9%)  i/s
     dalli_r  50%  hit      266.5 (±6.4%)  i/s
      memory 100% miss    15276.8 (±11.1%) i/s
      memory 100%  hit    29646.5 (±6.9%)  i/s
      memory  50%  hit    16537.5 (±9.1%)  i/s

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
