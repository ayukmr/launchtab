module LaunchTab
  # file parser
  module Parser
    class << self
      # parse lines from file
      def parse(lines)
        lines
          .map { |line| parse_line(line) }
          .compact
      end

      # parse line
      def parse_line(line)
        vals = line.strip.split

        if line.start_with?(/@[a-z]+/)
          error 'not enough values, expected two' if vals.length < 2

          # value presets
          presets = {
            hourly:   [[0], [:any], [:any], [:any], [:any]],
            daily:    [[0], [0],    [:any], [:any], [:any]],
            weekly:   [[0], [0],    [:any], [:any], [0]],
            monthly:  [[0], [0],    [1],    [:any], [:any]],
            yearly:   [[0], [0],    [1],    [1],    [:any]],
            annually: [[0], [0],    [1],    [1],    [:any]]
          }

          # get preset
          preset = presets[vals[0][1..].to_sym]
          error "invalid preset `#{vals[0]}`" unless preset

          # create service
          program = vals[1..].join(' ')
          LaunchTab::Service.new(preset, program)
        elsif !line.start_with?('#')
          error 'not enough values, expected six' if vals.length < 6

          # value constraints
          mins = [0,  0,  1,  1,  0]
          maxs = [59, 23, 31, 12, 6]

          # expand values
          expanded = mins.zip(maxs).zip(vals[..4]).map do |zip|
            min_max, val = zip
            min, max = min_max

            value(val, min, max)
          end

          # create service
          program = vals[5..].join(' ')
          LaunchTab::Service.new(expanded, program)
        end
      end

      # parse value
      def value(val, min, max)
        split = val.split(',')

        split.flat_map do |num|
          case num
          # single number
          when /^\d+$/
            [num.to_i]

          # range of values
          when '*', /^\d+-\d+$/
            range(num, max)

          # range steps
          when %r{^(\*|\d+-\d+)/\d+$}
            steps(num, min, max)

          else
            error "invalid value `#{val}`"
          end
        end.uniq
      end

      # parse ranges
      def range(val, max)
        case val
        # any value
        when '*'
          [:any]

        # value to max
        when /^\d+$/
          [*val.to_i..max]

        # value to value
        when /^\d+-\d+$/
          split = val.split('-')

          [*split[0].to_i..split[1].to_i]
        end
      end

      # parse range steps
      def steps(val, min, max)
        split = val.split('/')

        # create range
        range =
          if split[0] == '*'
            [*min..max]
          else
            range(split[0], max)
          end

        step = split[1].to_i

        # get steps from range
        range.filter { |num| (num % step).zero? }
      end
    end
  end
end
