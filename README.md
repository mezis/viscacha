# Lmc::Store

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'lmc-store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lmc-store

## Usage

TODO: Write usage instructions here

## Benchmarks

Bear in mind those are microbenchmarks, so your mileage may vary. The bottom
line is Viscacha will be considerably faster than Memcache in pretty much
all situations.

Comparing 5 cache stores using mordern hardware and networking (2.2GHz Core
i7, gigabit ethernet).

- Viscacha (running locally)
- `ActiveSupport::MemMacheStore` (using the `memcache-client`)
- `ActiveSupport::DalliStore` (using the `dalli` gem)
- `ActiveSupport::DalliStore` running off another machine
- `ActiveSupport::MemoryStore` for reference

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
5. Create new Pull Request
