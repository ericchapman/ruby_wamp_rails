require 'spec_helper'

describe WampRails::Worker::Thread do
  before(:all) {
    @worker = described_class.new({wamp: WampRailsTest::TestConnection.new({})})
    @worker.routes do
      add_procedure 'route.procedure', WampRailsTest::TestProcedureController
      add_subscription 'route.topic', WampRailsTest::TestSubscriptionController
    end
    @worker.open
    @worker.wait_for_active
    @client = @worker.new_client
  }

  after(:all) {
    @worker.close
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
        @client.register('test.procedure', WampRailsTest::TestProcedureController, {test: true}) do |result, error, details|
          expect(result.count).to eq(4)
          expect(result[0]).to eq('test.procedure')
          expect(error).to be_nil
        end
      end

      it 'processes an error' do
        @client.register('test.procedure', WampRailsTest::TestProcedureController, {error: true}) do |result, error, details|
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
        }.to raise_exception(WampRails::Error)
      end
    end

    describe 'subscribe' do
      it 'sends a subscribe command' do
        @client.subscribe('test.topic', WampRailsTest::TestSubscriptionController, {test: true}) do |result, error, details|
          expect(result.count).to eq(3)
          expect(result[0]).to eq('test.topic')
          expect(error).to be_nil
        end
      end

      it 'processes an error' do
        @client.subscribe('test.topic', WampRailsTest::TestSubscriptionController, {error: true}) do |result, error, details|
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
          @client.call('route.procedure', [4], {number: 5}) do |r, e, d|
            expect(r[0][0]).to eq(9)
          end
        end
      end

      describe 'subscribe' do
        it 'calls the controller' do
          @client.publish('route.topic', [5], {number:4}) do |r, e, d|
            expect(WampRailsTest::TestSubscriptionController.count).to eq(9)
          end
        end
      end
    end
  end
end
