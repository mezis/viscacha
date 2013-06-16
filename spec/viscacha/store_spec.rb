require 'spec_helper'
require 'viscacha/store'
require 'pathname'

describe Viscacha::Store do
  # def cache_file_path
  #   @cache_file_path ||= Pathname.new("tmp/test.#{$$}.lmc")
  # end
  # def remove_cache_file
  #   return unless cache_file_path.exist?
  #   cache_file_path.delete
  # end

  # before { remove_cache_file }
  # after  { remove_cache_file }

  describe 'cache behaviour' do
    subject { described_class.new directory:'tmp', name:$$ }
    before  { subject.clear }

    describe 'read/write/delete' do
      context 'when cache is empty' do
        it '#read returns nil' do
          subject.read('foo').should be_nil
        end

        it '#write returns true' do
          subject.write('foo', '1337').should be_true
        end

        it '#delete returns false' do
          subject.delete('foo').should be_false
        end
      end

      context 'when cache is not empty' do
        before do
          subject.write('foo', '1337')
        end

        it '#read returns cached value' do
          subject.read('foo').should eq('1337')
        end

        it '#write returns true' do
          subject.write('foo', '1338').should be_true
        end

        it '#delete returns true' do
          subject.delete('foo').should be_true
        end
      end

      it 'caches structured values' do
        data = { foo:12.34, bar:56, qux:nil }
        subject.write('foo', data)
        subject.read('foo').should eq(data)
      end
    end

    describe '#increment'
    describe '#decrement'
    describe '#cleanup'
    describe '#clear'

    describe '#fetch' do
      it 'persists values' do
        subject.fetch('foo') { '1337' }
        result = subject.fetch('foo') { '1338' }
        result.should == '1337'
      end

      it 'is lazy' do
        generator = stub value:'1337'
        generator.should_receive(:value).once

        2.times do
          subject.fetch('foo') { generator.value }
        end
      end
    end

    describe '#write'
    describe '#read'
    describe '#exist?'
    describe '#delete'
  end


  describe 'eviction' do
    def blob(size_mb)
      SecureRandom.random_bytes(size_mb.megabytes)
    end

    subject { described_class.new directory:'tmp', name:$$, size:16.megabytes }
    before  { subject.clear }

    it 'evicts items' do
      16.times do |index|
        subject.write(index.to_s, blob(1))
      end

      # backend = subject.send(:meta_store)
      # backend = subject.send(:data_store)
      # require 'pry' ; require 'pry-nav' ; binding.pry
    end

    it 'evicts the oldest item' do
      subject.write('foo', 'bar')
      16.times do |index|
        subject.write(index.to_s, blob(1))
      end

      subject.read('foo').should be_nil
    end

    it 'evicts the least recently used item' do
      subject.write '1', blob(3)
      # sleep 10e-3
      subject.write '2', blob(3)
      # sleep 10e-3
      subject.write '3', blob(3)
      # sleep 10e-3
      subject.read '1'
      # sleep 10e-3
      subject.write '4', blob(3)

      classes = (1..4).map { |index| subject.read(index.to_s).class }
      classes.should == [String, NilClass, String, String]
    end
  end

  describe 'persistence'

  describe 'supports concurrency' do
    # it 'in the same thread'
    # it 'across multiple threads'
    # it 'across multiple processes'
  end
end