require 'spec_helper'
require 'virtus'

module Plaster
  module WrappingListSpec

    class StringifyingWrapper
      include Virtus.model
      values do
        attribute :entry, String, lazy: true
      end
    end

    describe WrappingList do
      describe "a subclass using a stringifying wrapper" do
        subject{ subclass.new }
        let( :subclass ) { Class.new(described_class) do
          wrap_each StringifyingWrapper, :entry
        end }

        it "wraps each entry when it is written to an index position" do
          subject[0] = 'abc'
          subject[1] = 'def'
          expect( subject.inner_array ).to eq( [
            StringifyingWrapper.new(entry: 'abc'),
            StringifyingWrapper.new(entry: 'def')
          ] )
        end

        it "unwraps each entry when it is read from an index position" do
          subject.inner_array <<
            StringifyingWrapper.new(entry: 'aaa') <<
            StringifyingWrapper.new(entry: 'bbb')
          expect( subject[0] ).to eq('aaa')
          expect( subject[1] ).to eq('bbb')
        end

        describe '#each' do
          before do
            subject.inner_array <<
              StringifyingWrapper.new(entry: 'aaa') <<
              StringifyingWrapper.new(entry: 'bbb')
          end

          it "enumerates unwrapped entries when given a block" do
            yielded = []
            subject.each do |entry| ; yielded << entry ; end
            expect( yielded ).to eq( %w[aaa bbb] )
          end

          it "returns an enumerator for unwrapped entries when not given a block" do
            enumerator = subject.each
            expect( enumerator.next ).to eq('aaa')
            expect( enumerator.next ).to eq('bbb')
            expect{ enumerator.next }.to raise_exception( StopIteration )
          end
        end
      end
    end

  end
end
