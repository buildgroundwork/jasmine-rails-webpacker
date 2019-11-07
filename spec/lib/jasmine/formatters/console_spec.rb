# frozen_string_literal: true

require 'spec_helper'

describe Jasmine::Formatters::Console do
  let(:formatter) { described_class.new(outfile: outfile) }
  let(:outfile) { StringIO.new }
  let(:output) { outfile.tap(&:rewind).read }
  let(:run_details) { { 'order' => { 'random' => false } } }

  describe '#format' do
    it 'prints a dot for a successful spec' do
      formatter.format([passing_result])

      expect(output).to include('.')
    end

    it 'prints a star for a pending spec' do
      formatter.format([pending_result])

      expect(output).to include('*')
    end

    it 'prints an F for a failing spec' do
      formatter.format([failing_result])

      expect(output).to include('F')
    end

    it 'prints a dot for a disabled spec' do
      formatter.format([disabled_result])

      expect(output).to eq('')
    end
  end

  describe '#summary' do
    it 'shows the failure messages' do
      results = [failing_result, failing_result]
      formatter.format(results)
      formatter.done(run_details)
      expect(output).to match(/a suite with a failing spec/)
      expect(output).to match(/a failure message/)
      expect(output).to match(/a stack trace/)
    end

    describe 'when the full suite passes' do
      it 'shows the spec counts' do
        results = [passing_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/1 spec/)
        expect(output).to match(/0 failures/)
      end

      it 'shows the spec counts (pluralized)' do
        results = [passing_result, passing_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/2 specs/)
        expect(output).to match(/0 failures/)
      end
    end

    describe 'when there are failures' do
      it 'shows the spec counts' do
        results = [passing_result, failing_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/2 specs/)
        expect(output).to match(/1 failure/)
      end

      it 'shows the spec counts (pluralized)' do
        results = [failing_result, failing_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/2 specs/)
        expect(output).to match(/2 failures/)
      end

      it 'shows the failure message' do
        results = [failing_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/a failure message/)
      end
    end

    describe 'when there are pending specs' do
      it 'shows the spec counts' do
        results = [passing_result, pending_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/1 pending spec/)
      end

      it 'shows the spec counts (pluralized)' do
        results = [pending_result, pending_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/2 pending specs/)
      end

      it 'shows the pending reason' do
        results = [pending_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/I pend because/)
      end

      it 'shows the default pending reason' do
        results = [Jasmine::Result.new(pending_raw_result.merge('pendingReason' => ''))]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to match(/No reason given/)
      end
    end

    describe 'when there are no pending specs' do
      it 'should not mention pending specs' do
        results = [passing_result]
        formatter.format(results)
        formatter.done(run_details)

        expect(output).to_not match(/pending spec[s]/)
      end
    end

    describe 'when the tests were randomized' do
      it 'should print a message with the seed' do
        results = [passing_result]
        formatter.format(results)
        formatter.done('order' => { 'random' => true, 'seed' => '4325' })

        expect(output).to match(/Randomized with seed 4325 \(rake jasmine:ci\[true,4325\]\)/)
      end
    end

    describe 'with loading errors' do
      it 'should show the errors' do
        formatter.done('failedExpectations' => [
          {
            'globalErrorType' => 'load',
            'message' => 'Load Error',
            'stack' => 'more info'
          },
          {
            'globalErrorType' => 'load',
            'message' => 'Another Load Error',
            'stack' => 'even more info'
          }
        ])

        expect(output).to match(/Error during loading/)
        expect(output).to match(/\e\[31mLoad Error\e\[0m\n\s*Stack:\n\s*more info/)
        expect(output).to match(/\e\[31mAnother Load Error\e\[0m\n\s*Stack:\n\s*even more info/)
      end
    end

    describe 'with errors in a global afterAll' do
      it 'should show the errors' do
        formatter.done('failedExpectations' => [
          {
            'globalErrorType' => 'afterAll',
            'message' => 'Global Failure',
            'stack' => 'more info'
          },
          {
            'globalErrorType' => 'afterAll',
            'message' => 'Another Failure',
            'stack' => 'even more info'
          }
        ])

        expect(output).to match(/Error occurred in afterAll/)
        expect(output).to match(/\e\[31mGlobal Failure\e\[0m\n\s*Stack:\n\s*more info/)
        expect(output).to match(/\e\[31mAnother Failure\e\[0m\n\s*Stack:\n\s*even more info/)
      end
    end

    describe 'when the overall status is incomplete' do
      it 'shows the reason' do
        formatter.done(
          'overallStatus' => 'incomplete',
          'incompleteReason' => 'not all bars were frobnicated'
        )

        expect(output).to match(/Incomplete: not all bars were frobnicated/)
      end
    end

    it 'shows deprecation warnings' do
      formatter.format([Jasmine::Result.new(deprecation_raw_result)])
      formatter.done('deprecationWarnings' => [{ 'message' => 'globally deprecated', 'stack' => nil }])

      expect(output).to match(/deprecated call/)
      expect(output).to match(/globally deprecated/)
    end
  end

  def failing_result
    Jasmine::Result.new(failing_raw_result)
  end

  def passing_result
    Jasmine::Result.new(passing_raw_result)
  end

  def pending_result
    Jasmine::Result.new(pending_raw_result)
  end

  def disabled_result
    Jasmine::Result.new(disabled_raw_result)
  end
end

