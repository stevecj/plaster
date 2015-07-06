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

        it "wraps each item when it is written to an index position" do
          subject[0] = 'abc'
          subject[1] = 'def'
          expect( subject.inner_array ).to eq( [
            StringifyingWrapper.new(entry: 'abc'),
            StringifyingWrapper.new(entry: 'def')
          ] )
        end

        it "unwraps each item when it is read from an index position" do
          subject.inner_array <<
            StringifyingWrapper.new(entry: 'aaa') <<
            StringifyingWrapper.new(entry: 'bbb')
          expect( subject[0] ).to eq('aaa')
          expect( subject[1] ).to eq('bbb')
        end
      end
    end

  end
end
