# frozen_string_literal: true

require "spec_helper"

module ThreadUnsafe
  class IncrementerTest
    attr_accessor :sheep_counter

    def initialize
      @sheep_counter = 0
    end

    include Incrementer

    self.incrementable_attribute = :@sheep_counter
  end

  RSpec.describe Incrementer do
    let(:klass) { IncrementerTest }

    it "includes Incrementable methods self.__count" do
      expect(klass.new).to respond_to(:__count)
    end

    it "includes Incrementable methods self.__count=" do
      expect(klass.new).to respond_to(:__count=)
    end

    describe IncrementerTest do
      subject(:instance) { described_class.new }

      let(:initial) { 10 }

      before { instance.increment(by: initial) }

      describe "when incrementing in a single thread" do
        it "increments the counter to expected value" do
          expect(instance.__count).to eq(initial)
        end
      end

      describe "when incrementing in multiple threads" do
        let(:threads) { [] }
        let(:thread_count) { 20 }

        shared_examples_for "incrementer" do |add_delay: false, with_mutex: false, by: 1|
          before do
            instance.add_delay = add_delay

            thread_count.times do
              threads << Thread.new do
                instance.increment(with_mutex:, by:)
              end
            end

            threads.each(&:join)
          end

          describe "when delay: #{add_delay} | with_mutex: #{with_mutex}" do
            if add_delay && !with_mutex
              it "incrementor correctly updates the counter" do
                expect(instance.__count).not_to eq(initial + thread_count)
              end
            else
              it "incrementor corrupts the counter like a KGB Agent thats terrible at multi-tasking" do
                expect(instance.__count).to eq(initial + thread_count)
              end
            end
          end
        end

        it_behaves_like "incrementer", add_delay: true, with_mutex: true
        it_behaves_like "incrementer", add_delay: false, with_mutex: false
        it_behaves_like "incrementer", add_delay: true, with_mutex: false
      end
    end
  end
end
