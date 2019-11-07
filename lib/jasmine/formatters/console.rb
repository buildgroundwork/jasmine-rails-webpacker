# frozen_string_literal: true

module Jasmine
  module Formatters
    class Console
      def initialize(outfile: $stdout)
        @results = []
        @outfile = outfile
      end

      def format(results_batch)
        outfile.print(chars(results_batch))
        @results += results_batch
      end

      def done(run_details)
        outfile.puts

        run_result = global_failure_details(run_details)

        failure_count = results.count(&:failed?)
        if failure_count.nonzero?
          outfile.puts('Failures:')
          outfile.puts(failures(@results))
          outfile.puts
        end

        pending_count = results.count(&:pending?)
        if pending_count.nonzero?
          outfile.puts('Pending:')
          outfile.puts(pending(@results))
          outfile.puts
        end

        deprecation_warnings = (@results + [run_result]).collect(&:deprecation_warnings).flatten
        if deprecation_warnings.any?
          outfile.puts('Deprecations:')
          outfile.puts(deprecations(deprecation_warnings))
          outfile.puts
        end

        summary = "#{pluralize(results.size, 'spec')}, #{pluralize(failure_count, 'failure')}"
        summary += ", #{pluralize(pending_count, 'pending spec')}" if pending_count.nonzero?
        outfile.puts(summary)

        # rubocop:disable Style/IfUnlessModifier
        if run_details['overallStatus'] == 'incomplete'
          outfile.puts("Incomplete: #{run_details['incompleteReason']}")
        end
        # rubocop:enable Style/IfUnlessModifier

        if run_details['order'] && run_details['order']['random']
          seed = run_details['order']['seed']
          outfile.puts("Randomized with seed #{seed} \(rake jasmine:ci\[true,#{seed}])")
        end
      end

      private

      attr_reader :results, :outfile

      def failures(results)
        results.select(&:failed?).collect { |f| failure_message(f) }.join("\n\n")
      end

      def pending(results)
        results.select(&:pending?).collect { |spec| pending_message(spec) }.join("\n\n")
      end

      def deprecations(warnings)
        warnings.collect { |w| expectation_message(w) }.join("\n\n")
      end

      def global_failure_details(run_details)
        result = Jasmine::Result.new(run_details.merge('fullName' => 'Error occurred in afterAll', 'description' => ''))
        if result.failed_expectations.any?
          (load_fails, after_all_fails) = result.failed_expectations.partition { |e| e.globalErrorType == 'load' }
          report_global_failures('Error during loading', load_fails)
          report_global_failures('Error occurred in afterAll', after_all_fails)
        end

        result
      end

      def report_global_failures(prefix, fails)
        if fails.any?
          fail_result = Jasmine::Result.new('fullName' => prefix, 'description' => '', 'failedExpectations' => fails)
          outfile.puts(failure_message(fail_result))
          outfile.puts
        end
      end

      def chars(results)
        colorized = results.collect do |result|
          if result.succeeded?
            "\e[32m.\e[0m"
          elsif result.pending?
            "\e[33m*\e[0m"
          elsif result.disabled?
            ''
          else
            "\e[31mF\e[0m"
          end
        end

        colorized.join('')
      end

      def pluralize(count, str)
        "#{count} #{count == 1 ? str : str + 's'}"
      end

      def pending_message(spec)
        reason = 'No reason given'
        reason = spec.pending_reason if spec.pending_reason && spec.pending_reason != ''

        "\t#{spec.full_name}\n\t  \e[33m#{reason}\e[0m"
      end

      def failure_message(failure)
        failure.full_name + "\n" + failure.failed_expectations.collect { |fe| expectation_message(fe) }.join("\n")
      end

      def expectation_message(expectation)
        <<-FE
  Message:
      \e[31m#{expectation.message}\e[0m
  Stack:
      #{stack(expectation.stack)}
        FE
      end

      def stack(stack)
        stack.split("\n").collect(&:strip).join("\n      ")
      end
    end
  end
end

