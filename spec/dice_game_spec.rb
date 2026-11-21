RSpec.describe DiceGame do
  it "имеет номер версии" do
    expect(DiceGame::VERSION).not_to be nil
  end
  it "подсчитывает общий счет с данным броском" do
    game = DiceGame.new
    expect(game.calculate(1, 3, 4, 5, 6)).to eq(19)
  end
  it "подсчитывает общий балл с парой" do
    game = DiceGame.new
    expect(game.calculate(2, 2, 4, 5, 6)).to eq(29)
  end
  it "вычисляет общий балл по нескольким парам" do
    game = DiceGame.new
    expect(game.calculate(3, 3, 5, 5, 1)).to eq(37)
  end
  it "подсчитывает общий балл с тройкой" do
    game = DiceGame.new
    expect(game.calculate(4, 4, 4, 2, 1)).to eq(35)
  end
  it "подсчитывает общий балл с четверкой" do
    game = DiceGame.new
    expect(game.calculate(6, 6, 6, 6, 3)).to eq(67)
  end
  it "подсчитывает общий балл с помощью прямой" do
    game = DiceGame.new
    expect(game.calculate(1, 2, 3, 4, 5)).to eq(45)
    expect(game.calculate(1, 2, 2, 2, 5)).to eq(32)
  end
  it "подсчитывает счет с помощью кубика «стрит + шестерка»" do
    game = DiceGame.new
    expect(game.calculate(5, 3, 2, 6, 1, 4)).to eq(51)
  end
  it "вычисляет пятёрки" do
    game = DiceGame.new
    expect(game.calculate(1, 1, 2, 1, 1, 1)).to eq(57)
  end
  it "вычисляет шестерки" do
    game = DiceGame.new
    expect(game.calculate(2, 2, 2, 2, 2, 2)).to eq(112)
  end
  it "подсчитывает общий балл, включая наклейку с множителем" do
    game = DiceGame.new
    sticker = DiceGame::Sticker::Multiplier.new(value: 2)
    expect(game.calculate(1, 3, 4, 4, 5, sticker)).to eq(54)
  end
  it "подсчитывает общий балл, включая две наклейки с множителем" do
    game = DiceGame.new
    sticker = DiceGame::Sticker::Multiplier.new(value: 2)
    sticker2 = DiceGame::Sticker::Multiplier.new(value: 3)
    expect(game.calculate(1, 3, 4, 4, 5, sticker, sticker2)).to eq(162)
  end
  it "подсчитывает сумму, используя стикер сложения и стикер множителя" do
    game = DiceGame.new
    multiplier_sticker = DiceGame::Sticker::Multiplier.new(value: 3)
    addition_sticker = DiceGame::Sticker::Addition.new(value: 10)
    expect(game.calculate(2, 2, 3, 4, addition_sticker, multiplier_sticker)).to eq(93)
  end
  it "вычисляет 5 шестерок и наклейку с множителем 2x" do
    game = DiceGame.new
    sticker = DiceGame::Sticker::Multiplier.new(value: 2)
    expect(game.calculate(6, 6, 6, 6, 6, sticker)).to eq(160)
  end
  it "вычисляет 6, 6, 6, 6, 6, 6, 6, x2" do
    game = DiceGame.new
    sticker = DiceGame::Sticker::Multiplier.new(value: 2)
    expect(game.calculate(6, 6, 6, 6, 6, 6, 6, sticker)).to eq(284)
  end
  it "рассчитывает 3, 4, 6, 7, 8, 9 как НЕ стрит" do
    game = DiceGame.new
    expect(game.calculate(3, 4, 6, 7, 8, 9)).to eq(37)
  end
  context "#рулон" do
    it "возвращает массив значений брошенных кубиков" do
      game = DiceGame.new
      die1 = DiceGame::Die.new
      die2 = DiceGame::Die.new
      die3 = DiceGame::Die.new
      rolls = game.roll(die1, die2, die3)
      expect(rolls.length).to eq(3)
      rolls.each do |roll|
        expect(roll).to be_between(1, 6).inclusive
      end
    end
    it "бросает кубик, в том числе с наклейкой" do
      sticker = DiceGame::Sticker::Multiplier.new(value: 2)
      die_with_sticker = DiceGame::Die.new(faces: [1, 2, 3, 4, 5, sticker])
      roll = die_with_sticker.roll
      expect([1, 2, 3, 4, 5, sticker]).to include(roll)
    end
  end
end