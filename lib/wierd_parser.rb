class WierdParser
  IDENTIFIER_CHARACTERS = /[a-zA-Z]/
  DIGITS = /[0-9]/
  WHITESPACE = /\s/

  def self.parse_string(input)
    parse_io(StringIO.new(input))
  end

  def self.parse_io(input)
    new(input).__send__(:parse_hash_pairs)
  end

  private

    def initialize(input)
      @input = input
      @peeked = []
      @line_no = 1
    end

    def parse_value
      skip_whitespace!
      next_ch = peek_ch

      case next_ch
      when '"' then parse_string
      when IDENTIFIER_CHARACTERS then parse_identifier
      when DIGITS then parse_number
      when '{' then parse_hash
      when nil then nil # finished
      else raise parse_error("Unexpected character: #{next_ch}")
      end
    end

    def parse_hash
      take!('{')
      result = parse_hash_pairs
      take!('}')
      result
    end

    def parse_hash_pairs
      {}.tap do |pairs|
        loop do
          skip_whitespace!
          break if peek_ch == '}' || peek_ch == nil

          key = parse_value
          skip_whitespace!

          # check for wierd single value hashes
          if pairs.size == 0 && peek_ch == '}'
            return key
          end

          take!('=')
          skip_whitespace!
          value = parse_value

          pairs[key] = value
        end
      end
    end

    def parse_identifier
      identifier = ""

      while IDENTIFIER_CHARACTERS.match?(peek_ch) do
        identifier << read_ch!
      end

      identifier.to_sym
    end

    def parse_string
      result = ""

      take!('"')
      while peek_ch != '"' do #TODO: doesn't handle escaping
        result << read_ch!
      end
      take!('"')

      result
    end

    def parse_number
      result = ""

      loop do
        if DIGITS.match?(peek_ch) || (peek_ch == '.' && !result.include?('.'))
          result << read_ch!
        else
          break
        end
      end

      if result.include?('.')
        Float(result)
      else
        Integer(result, 10)
      end
    end

    def peek_ch
      return @peeked.first if @peeked.any?

      char = @input.getc
      @peeked << char
      char
    end

    def read_ch!
      if @peeked.empty?
        @input.getc
      else
        @peeked.shift
      end
    end

    def take!(expected_ch)
      actual_ch = read_ch!
      if expected_ch != actual_ch
        raise parse_error("Expected '#{expected_ch}' but got a '#{actual_ch}'")
      end
    end

    def skip_whitespace!
      while WHITESPACE.match?(peek_ch)
        ch = read_ch!
        @line_no += 1 if ch == "\n"
      end
    end

    def parse_error(message)
      ParseError.new("On line #{@line_no}: " + message)
    end

    class ParseError < StandardError; end
end
