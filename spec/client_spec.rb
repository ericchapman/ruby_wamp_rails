require 'spec_helper'

describe WampRails::Client do
  before(:each) {
    @client = described_class.new({wamp: WampRailsTest::TestConnection.new({})})
    until @client.is_active?
    end
  }

  after(:each) {
    @client.close
  }

  describe 'commands' do
    describe 'call' do
      it 'sends a call command' do
        @client.call('test.procedure', ['test'], {test: true}) do |result, error, details|
          expect(result.count).to eq(4)
          expect(result[0]).to eq('test.procedure')
          expect(error).to be_nil
        end
      end

      it 'processes an error' do
        @client.call('test.procedure', ['test'], {test: true}, {error: true}) do |result, error, details|
          expect(result).to be_nil
          expect(error[:error]).to eq('wamp_rails.error')
          expect(error[:args][0]).to eq('test exception')
        end
      end

    end

    describe 'publish' do
      it 'sends a publish command' do
        @client.publish('test.topic', ['test'], {test: true}) do |result, error, details|
          expect(result.count).to eq(4)
          expect(result[0]).to eq('test.topic')
          expect(error).to be_nil
        end
      end

      it 'processes an error' do
        @client.publish('test.topic', ['test'], {test: true}, {error: true}) do |result, error, details|
          expect(result).to be_nil
          expect(error[:error]).to eq('wamp_rails.error')
          expect(error[:args][0]).to eq('test exception')
        end
      end
    end

    describe 'register' do
      it 'sends a register command' do
        @client.register('test.procedure', WampRailsTest::TestRegisterController, {test: true}) do |result, error, details|
          expect(result.count).to eq(4)
          expect(result[0]).to eq('test.procedure')
          expect(error).to be_nil
        end
      end

      it 'processes an error' do
        @client.register('test.procedure', WampRailsTest::TestRegisterController, {error: true}) do |result, error, details|
          expect(result).to be_nil
          expect(error[:error]).to eq('wamp_rails.error')
          expect(error[:args][0]).to eq('test exception')
        end
      end

      it 'raises an error when the class is incorrect' do
        expect {
          @client.register('test.procedure', Exception) do |result, error, details|
            expect(result).to be_nil
            expect(error[:error]).to eq('wamp_rails.error')
          end
        }.to raise_exception(Exception)
      end
    end

    describe 'subscribe' do
      it 'sends a subscribe command' do
        @client.subscribe('test.topic', WampRailsTest::TestSubscribeController, {test: true}) do |result, error, details|
          expect(result.count).to eq(3)
          expect(result[0]).to eq('test.topic')
          expect(error).to be_nil
        end
      end

      it 'processes an error' do
        @client.subscribe('test.topic', WampRailsTest::TestSubscribeController, {error: true}) do |result, error, details|
          expect(result).to be_nil
          expect(error[:error]).to eq('wamp_rails.error')
          expect(error[:args][0]).to eq('test exception')
        end
      end

      it 'raises an error when the class is incorrect' do
        expect {
          @client.subscribe('test.topic', Exception) do |result, error, details|
            expect(result).to be_nil
            expect(error[:error]).to eq('wamp_rails.error')
          end
        }.to raise_exception(Exception)
      end
    end

    describe 'controllers' do

      describe 'register' do
        it 'calls the controller' do
          @client.register('test.procedure', WampRailsTest::TestRegisterController) do |result, error, details|
            @client.call('test.procedure', [4], {number: 5}) do |r, e, d|
              expect(r[0][0]).to eq(9)
            end
          end
        end
      end

      describe 'subscribe' do
        it 'calls the controller' do
          @client.subscribe('test.topic', WampRailsTest::TestSubscribeController) do |results, error, deatils|
            @client.publish('test.topic', [5], {number:4}) do |r, e, d|
              expect(WampRailsTest::TestSubscribeController.count).to eq(9)
            end
          end
        end
      end
    end
  end
end
