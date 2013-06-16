require 'spec_helper'
require 'viscacha/store'
require 'pathname'

describe Viscacha::Store do
  def cache_file_path
    @cache_file_path ||= Pathname.new('test.lmc')
  end
  def remove_cache_file
    return unless cache_file_path.exist?
    cache_file_path.delete
  end

  before { remove_cache_file }
  after  { remove_cache_file }

  describe 'cache behaviour' do
    subject { described_class.new filename:cache_file_path }

    describe 'read/write/delete' do
      context 'when cache is empty' do
        it '#read_entry returns nil' do
          subject.send(:read_entry, 'foo').should be_nil
        end

        it '#write_entry returns true' do
          subject.send(:write_entry, 'foo', '1337').should be_true
        end

        it '#delete_entry returns false' do
          subject.send(:delete_entry, 'foo').should be_false
        end
      end

      context 'when cache is not empty' do
        before do
          subject.send(:write_entry, 'foo', '1337')
        end

        it '#read_entry returns cached value' do
          subject.send(:read_entry, 'foo').should eq('1337')
        end

        it '#write_entry returns true' do
          subject.send(:write_entry, 'foo', '1338').should be_true
        end

        it '#delete_entry returns true' do
          subject.send(:delete_entry, 'foo').should be_true
        end
      end

      it 'caches structured values' do
        data = { foo:12.34, bar:56, qux:nil }
        subject.send(:write_entry, 'foo', data)
        subject.send(:read_entry, 'foo').should eq(data)
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
    subject { described_class.new filename:cache_file_path, size:1 }
    
    it 'evicts items' do
      11.times do |time|
        subject.write time.to_s, ("x" * 128.kilobytes)
      end
    end

    it 'evicts the oldest item' do
      subject.write('foo', 'bar')
      10.times do |time|
        subject.write time.to_s, ("x" * 128.kilobytes)
      end      

      subject.read('foo').should be_nil
    end

    it 'evicts the least recently used item' do
      subject.write '1', ('x' * 256.kilobytes)
      subject.write '2', ('x' * 256.kilobytes)
      subject.write '3', ('x' * 256.kilobytes)
      subject.read '1'
      subject.write '4', ("x" * 256.kilobytes)

      subject.read("1").should_not be_nil
      subject.read("2").should be_nil
    end
  end

  describe 'persistence'

  describe 'supports concurrency' do
    # it 'in the same thread'
    # it 'across multiple threads'
    # it 'across multiple processes'
  end
end