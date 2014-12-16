require 'yaml'
require 'byebug'
require_relative './board'
require_relative './tile'

class Game
  attr_reader :board

  def initialize
    @board = start_game
  end

  def start_game
    puts "New Game or Load from Disk? (n/l)"
    selection = gets.chomp
    if selection == 'l'
      puts "Please input filename"
      filename = gets.chomp
      content = File.read("#{filename}.yml")
      YAML::load(content)
    else
      puts "Please input board size: "
      size = gets.chomp.to_i
      puts "Please enter the number of bombs: "
      bombs = gets.chomp.to_i
      Board.new(size, bombs)
    end
  end

  def play
    board.render
    until board.won?
      coordinates, move = get_move
      if move == 'r'
        board[coordinates].reveal
        break if board[coordinates].bombed?
      elsif move == 'f'
        board[coordinates].toggle_flag
      end
      break if board.won?
      board.render
      if save?
        save
        puts "Game saved."
        return
      end
    end

    puts (board.won? ? "You won" : "You lose")

    board.render(true)
  end

  def save?
    puts "Continue or Save? (c/s) "
    response = gets.chomp
    response == 's' ? true : false
  end

  def save
    puts "Please input filename: "
    filename = gets.chomp
    saved_board = board.to_yaml
    File.open("#{filename}.yml", "w") do |f|
      f.puts saved_board
    end
  end

  def get_move
    puts "Please select a coordinate"
    coordinates = gets.chomp.split(' ').map(&:to_i)
    puts "Reveal or Flag? (r/f)"
    move = gets.chomp
    [coordinates, move]
  end
end

g = Game.new
g.play
