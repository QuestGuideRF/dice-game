class DiceGame
  class Sticker
    class Multiplier < Sticker
      attr_reader :value
      def initialize(value:)
        @value = value
      end
      def inspect
        "х#{value}"
      end
      def to_s
        "х#{value}"
      end
      def apply(score)
        score * value
      end
    end
  end
end