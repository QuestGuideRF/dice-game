class DiceGame
  class Sticker
    def self.build(sticker)
      case sticker
      when /\d+x/
        value = sticker.to_i
        Multiplier.new(value: value)
      when /\+\d+/
        value = sticker[1..-1].to_i
        Addition.new(value: value)
      else
        raise "Неизвестный тип стикера: #{sticker}"
      end
    end
  end
end