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

    Calculating -------------------------------------
          viscacha write      3555 i/100ms
           viscacha read      4579 i/100ms
          memcache write       556 i/100ms
           memcache read       536 i/100ms
             dalli write       951 i/100ms
              dalli read       933 i/100ms
           dalli_r write        73 i/100ms
            dalli_r read        86 i/100ms
      memory_store write      4685 i/100ms
       memory_store read      5835 i/100ms
    -------------------------------------------------
          viscacha write    44975.8 (±2.4%) i/s -     227520 in   5.062050s
           viscacha read    60046.7 (±6.4%) i/s -     302214 in   5.055697s
          memcache write     5677.6 (±5.2%) i/s -      28356 in   5.008353s
           memcache read     5847.3 (±4.6%) i/s -      29480 in   5.052357s
             dalli write    10724.7 (±8.1%) i/s -      53256 in   4.998516s
              dalli read    10036.6 (±10.9%) i/s -      50382 in   5.092246s
           dalli_r write      761.0 (±2.5%) i/s -       3869 in   5.087344s
            dalli_r read      855.3 (±2.7%) i/s -       4300 in   5.031463s
      memory_store write    60977.1 (±11.6%) i/s -     304525 in   5.056969s
       memory_store read    79759.3 (±10.2%) i/s -     396780 in   5.019839s

23kb data (a fairly large HTML fragment for instance):

    Calculating -------------------------------------
          viscacha write      1075 i/100ms
           viscacha read      1099 i/100ms
          memcache write       332 i/100ms
           memcache read       258 i/100ms
             dalli write       509 i/100ms
              dalli read       492 i/100ms
           dalli_r write        41 i/100ms
            dalli_r read        37 i/100ms
      memory_store write      1997 i/100ms
       memory_store read      2601 i/100ms
    -------------------------------------------------
          viscacha write    11508.2 (±7.0%) i/s -      58050 in   5.068711s
           viscacha read    11836.4 (±9.1%) i/s -      59346 in   5.057104s
          memcache write     3611.7 (±1.9%) i/s -      18260 in   5.057570s
           memcache read     2842.3 (±5.1%) i/s -      14190 in   5.006016s
             dalli write     5577.3 (±4.5%) i/s -      27995 in   5.029034s
              dalli read     5402.3 (±4.5%) i/s -      27060 in   5.019419s
           dalli_r write      420.4 (±3.6%) i/s -       2132 in   5.078315s
            dalli_r read      385.0 (±2.9%) i/s -       1924 in   5.001414s
      memory_store write    20059.3 (±12.8%) i/s -      99850 in   5.081357s
       memory_store read    30785.0 (±8.9%) i/s -     153459 in   5.024036s


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
