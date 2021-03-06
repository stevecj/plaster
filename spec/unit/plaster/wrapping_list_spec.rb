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

    class Fruit < Struct.new(:name, :color)
    end

    class FructifyingWrapper
      include Virtus.model
      values do
        attribute :entry, Fruit, lazy: true
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

        it "fills implicitly-created positions with new wrapper instances" do
          subject[0] = 'abc'
          subject[3] = 'def'
          expect( subject.inner_array ).to eq( [
            StringifyingWrapper.new(entry: 'abc'),
            StringifyingWrapper.new,
            StringifyingWrapper.new,
            StringifyingWrapper.new(entry: 'def')
          ] )
        end

        context "enumeration" do
          before do
            subject.inner_array <<
              StringifyingWrapper.new(entry: 'aaa') <<
              StringifyingWrapper.new(entry: 'bbb')
          end

          describe '#each' do
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

          it "is enumerable over unwrapped entries" do
            expect( subject.entries ).to eq( %w[aaa bbb] )
          end
        end

        it "pushes wrapped entries onto end of list" do
          subject.push 'aaa', 'bbb'
          subject << 'ccc'
          expect( subject.inner_array ).to eq( [
            StringifyingWrapper.new(entry: 'aaa'),
            StringifyingWrapper.new(entry: 'bbb'),
            StringifyingWrapper.new(entry: 'ccc')
          ] )
        end
      end

      describe "a subclass using a struct-containing wrapper" do
        subject{ subclass.new }
        let( :subclass ) { Class.new(described_class) do
          wrap_each FructifyingWrapper, :entry
        end }

        it "returns deconstructed contents via #model_deconstruct" do
          subject <<
            Fruit.new('banana', 'yellow') <<
            Fruit.new('tomato', 'red')
          expect( subject.model_deconstruct ).to eq( [
            HashWIA.new(name: 'banana', color: 'yellow'),
            HashWIA.new(name: 'tomato', color: 'red')
          ] )
        end
      end
    end

  end
end
