require_relative "dice_game/version"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup
class DiceGame
  class Error < StandardError; end
  PAIR_BONUS = 10
  TRIPLE_BONUS = 20
  STRAIGHT_BONUS = 30
  QUAD_BONUS = 40
  FIVE_BONUS = 50
  SIX_BONUS = 100
  def roll(*dice)
    dice.map(&:roll)
  end
  def calculation_output(*rolls)
    total = numeric_rolls(*rolls).sum
    sixes = sixes(*rolls)
    fives = fives(*rolls)
    quads = quads(*rolls)
    triples = triples(*rolls)
    pairs = pairs(*rolls)
    output = []
    output << "Базовая сумма по числовым броскам: #{total}"
    output << "Пары (#{pairs}): +#{PAIR_BONUS * pairs}" if pairs > 0
    output << "Тройки (#{triples}): +#{TRIPLE_BONUS * triples}" if triples > 0
    output << "Четверные (#{quads}): +#{QUAD_BONUS * quads}" if quads > 0
    output << "Пятерки (#{fives}): +#{FIVE_BONUS * fives}" if fives > 0
    output << "Шестерки (#{sixes}): +#{SIX_BONUS * sixes}" if sixes > 0
    output << "Прямой бонус: +#{STRAIGHT_BONUS}" if straight?(rolls)
    output << "Total with bonuses: #{calculate_bonuses(*rolls)}"
    addition_rolls(*rolls).each do |sticker|
      output << "Дополнительная наклейка #{sticker.inspect}: +#{sticker.value}"
    end
    multiplier_rolls(*rolls).each do |sticker|
      output << "Наклейка-множитель #{sticker.inspect}: x#{sticker.value}"
    end
    output
  end
  def calculate(*rolls)
    total = calculate_bonuses(*rolls)
    total = calculate_stickers(total, *rolls)
    total.ceil
  end
  def calculate_stickers(total, *rolls)
    (addition_rolls(*rolls) + multiplier_rolls(*rolls)).reduce(total) do |acc, sticker|
      sticker.apply(acc)
    end
  end
  def calculate_bonuses(*rolls)
    total = numeric_rolls(*rolls).sum
    sixes = sixes(*rolls)
    fives = fives(*rolls)
    quads = quads(*rolls)
    triples = triples(*rolls)
    pairs = pairs(*rolls)
    total += QUAD_BONUS * quads
    total += TRIPLE_BONUS * triples
    total += PAIR_BONUS * pairs
    total += STRAIGHT_BONUS if straight?(rolls)
    total += FIVE_BONUS * fives
    total += SIX_BONUS * sixes
  end
  def pairs(*rolls)
    counts = Hash.new(0)
    rolls.each { |roll| counts[roll] += 1 }
    counts.values.count { |count| count == 2 }
  end
  def triples(*rolls)
    counts = Hash.new(0)
    rolls.each { |roll| counts[roll] += 1 }
    counts.values.count { |count| count == 3 }
  end
  def quads(*rolls)
    counts = Hash.new(0)
    rolls.each { |roll| counts[roll] += 1 }
    counts.values.count { |count| count == 4 }
  end
  def fives(*rolls)
    counts = Hash.new(0)
    rolls.each { |roll| counts[roll] += 1 }
    counts.values.count { |count| count == 5 }
  end
  def sixes(*rolls)
    counts = Hash.new(0)
    rolls.each { |roll| counts[roll] += 1 }
    counts.values.count { |count| count >= 6 }
  end
  def straight?(rolls)
    numeric_rolls(*rolls).sort.each_cons(5).any? do |sequence|
      sequence.each_cons(2).all? { |a, b| b == a + 1 }
    end
  end
  def numeric_rolls(*rolls)
    rolls.select { |roll| roll.is_a?(Numeric) }
  end
  def addition_rolls(*rolls)
    rolls.select { |roll| roll.is_a?(Sticker::Addition) }
  end
  def multiplier_rolls(*rolls)
    rolls.select { |roll| roll.is_a?(Sticker::Multiplier) }
  end
end
loader.eager_load