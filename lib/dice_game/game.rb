require "rainbow"
class DiceGame
  class Game
    BASE_SCORE = 50
    ROUND_MULTIPLIER = 1.52
    TARGET_SCORES = 1.upto(10).map { |round| (BASE_SCORE * (ROUND_MULTIPLIER*round)).to_i }
    attr_reader :dice, :score, :max_rolls_per_round, :rolls_this_round, :round
    def initialize
      @dice = 6.times.map { DiceGame::Die.random }
      @score = 0
      @max_rolls_per_round = 5
      @rolls_this_round = 0
      @round = 1
      @over = false
      @won = false
    end
    def add_score(*rolls)
      @score += DiceGame.new.calculate(*rolls)
    end
    def next_round!
      @round += 1
      @score = 0
      @rolls_this_round = 0
    end
    def over?
      !!@over
    end
    def won?
      !!@won
    end
    def passed_final_round?
      round >= TARGET_SCORES.size
    end
    def roll!
      rolls = dice.map(&:roll)
      add_score(*rolls)
      @rolls_this_round += 1
      rolls
    end
    def won_round?
      score >= TARGET_SCORES[round - 1]
    end
    def lost_round?
      rolls_this_round >= max_rolls_per_round && !won_round?
    end
    def add_upgrade(upgrade)
      case upgrade
      when :add_die
        new_die = DiceGame::Upgrades::AddDie.random_die
        @dice << new_die
        new_die
      when :add_sticker
        sticker = DiceGame::Upgrades::AddSticker.random_sticker
        @dice.sample.add_sticker(sticker)
        sticker
      when :random
        add_upgrade([:add_die, :add_sticker].sample)
      else
        raise "Неизвестное обновление: #{upgrade}"
      end
    end
    def report_status
      puts "Раунд №{round}/#{TARGET_SCORES.size}"
      puts "Оценка: #{score}"
      puts "Цель: #{TARGET_SCORES[round - 1]}"
      puts "Роллы: #{rolls_this_round}/#{max_rolls_per_round}"
    end
    def winner_winner!
      @won = true
      @over = true
    end
    def dice_pool
      Rainbow("Запас кубиков: #{dice.map(&:to_s).join(', ')}").bg(:yellow).black
    end
    def run
      puts "Добро пожаловать в игру в кости!"
      puts "Набирайте как минимум заданное количество очков в каждом раунде, чтобы продвинуться вперед."
      puts Rainbow("Вы начинаете с набором из 6 случайных кубиков.").bg(:yellow).black
      puts dice_pool
      while round <= TARGET_SCORES.size
        while score < TARGET_SCORES[round - 1] && rolls_this_round <= max_rolls_per_round
          puts "-------------------------"
          report_status
          puts dice_pool
          puts "Нажмите Enter, чтобы бросить кубик..."
          gets
          rolls = roll!
          numeric_rolls = rolls.select { |r| r.is_a?(Numeric) }
          non_numeric_rolls = rolls.reject { |r| r.is_a?(Numeric) }
          roll_stats = "Вы выпали: #{numeric_rolls.sort.join(', ')}"
          roll_stats += ", " + non_numeric_rolls.map(&:to_s).join(' ') unless non_numeric_rolls.empty?
          puts Rainbow(roll_stats).green
          output = DiceGame.new.calculation_output(*rolls)
          roll_score = DiceGame.new.calculate(*rolls)
          output.each do |line|
            puts Rainbow(line).green
            sleep(0.5)
          end
          puts Rainbow("Оценка броска: #{roll_score}").green
          sleep(0.5)
          puts Rainbow("Новый результат: #{score}!").green
          sleep(1)
        end
        if lost_round?
          puts Rainbow("Итоговый счет: #{score}").red
          puts Rainbow("К сожалению, вы не достигли заданного балла. Игра закончена!").red
          break
        end
        puts Rainbow("Итоговый счет: #{score}").green
        puts Rainbow("Цель: #{TARGET_SCORES[round - 1]}").green
        puts "--------------------------"
        puts Rainbow("Поздравляем! Вы завершили раунд №{round}!").bg(:green).black
        if passed_final_round?
          puts Rainbow("Вы прошли все раунды! Вы выиграли!").bg(:green).black
          winner_winner!
          break
        end
        puts Rainbow("Запас кубиков: #{dice.map(&:to_s).join(', ')}").bg(:yellow).black
        loop do
          puts "Хотите добавить случайный кубик или случайную наклейку в набор кубиков?"
          puts "1. Добавьте случайный кубик (d4 -> d20)."
          puts "2. Добавьте ЛИБО одну мульти-наклейку к случайному кубику, либо добавьте ДВЕ дополнительные наклейки."
          puts "3. Нет, спасибо, переходим к следующему раунду."
          choice = gets.chomp
          case choice
          when "1"
            new_die = add_upgrade(:add_die)
            puts Rainbow("Вы добавили #{new_die} в свой пул!").green
            break
          when "2"
            new_sticker = add_upgrade(:add_sticker)
            if new_sticker.is_a?(DiceGame::Sticker::Addition)
              puts Rainbow("Вы добавили ДВА стикера +#{new_sticker.value} на один из своих кубиков!").green
            else
              puts Rainbow("Вы добавили #{new_sticker} на один из своих кубиков!").green
            end
            break
          when "3"
            puts Rainbow("Продолжаем следующий раунд...").green
            break
          else
            puts Rainbow("Неверный выбор.").red
          end
          choice = nil
        end
        next_round!
      end
    end
  end
end