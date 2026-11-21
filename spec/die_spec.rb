require "spec_helper"
RSpec.describe DiceGame::Die do
  describe ".build" do
    it "строит кубик с заданными гранями" do
      die = DiceGame::Die.build(faces: 8)
      expect(die.faces).to eq((1..8).to_a)
    end
    it "собирает кубик с наклейками" do
      multiplier_sticker = DiceGame::Sticker::Multiplier.new(value: 3)
      die = DiceGame::Die.build(faces: 8, stickers: [multiplier_sticker])
      expect(die.faces.count).to eq(8)
      expect(die.faces).to include(multiplier_sticker)
    end
  end
  describe "#to_s со стикером-множителем" do
    it "возвращает строковое представление кубика" do
      multiplier_sticker = DiceGame::Sticker::Multiplier.new(value: 2)
      die = DiceGame::Die.build(faces: 6, stickers: [multiplier_sticker])
      expect(die.to_s).to eq("d6 (+1 x2)")
    end
  end
  describe "#add_sticker" do
    it "добавляет наклейку на кубик" do
      die = DiceGame::Die.new
      sticker = DiceGame::Sticker::Addition.new(value: 5)
      die.add_sticker(sticker)
      expect(die.faces).to include(sticker)
      expect(die.faces.count).to eq(6)
    end
  end
end