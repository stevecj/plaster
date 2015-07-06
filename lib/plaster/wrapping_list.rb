module Plaster

  class WrappingList

    class << self
      attr_reader :wrapper_class, :wrapper_attrib

      def wrapper_attrib_writer
        @wrapper_attrib_writer ||= :"#{wrapper_attrib}="
      end

      private

      def wrap_each(klass, attrib)
        @wrapper_class = klass
        @wrapper_attrib = attrib
      end
    end

    include Enumerable

    attr_reader :inner_array

    def initialize
      @inner_array = []
    end

    def []=(index, value)
      old_length = inner_array.length
      wrapper = (
        inner_array[index] ||= self.class.wrapper_class.new
      )
      wrapper.send self.class.wrapper_attrib_writer, value
      if index > old_length
        (old_length...index).each do |fill_idx|
          inner_array[fill_idx] = self.class.wrapper_class.new
        end
      end
      value
    end

    def [](index)
      wrapper = inner_array[index]
      wrapper.send self.class.wrapper_attrib
    end

    def each
      return Enumerator.new(self, :each) unless block_given?
      inner_array.each do |wrapper|
        value = wrapper.send(self.class.wrapper_attrib)
        yield value
      end
    end

    def <<(value)
      wrapper = self.class.wrapper_class.new
      wrapper.send self.class.wrapper_attrib_writer, value
      inner_array << wrapper
    end

    def push(*values)
      values.each do |value|
        self << value
      end
    end

  end

end
