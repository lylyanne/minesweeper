require 'yaml'
require 'byebug'

class Tile
  DELTAS = [[-1, -1], [-1, 0], [-1, 1], [0, 1],
  [1, 1], [1, 0], [1, -1], [0, -1]]

  attr_writer :bombed
  attr_accessor :flagged
  attr_reader :board

  def initialize(board, pos)
    @board, @pos = board, pos
    @bombed, @flagged, @revealed = false, false, false
  end

  def bombed?
    @bombed
  end

  def flagged?
    @flagged
  end

  def flag
    flagged? ? self.flagged = false : self.flagged = true
  end

  def revealed?
    @revealed
  end

  def reveal
    return if revealed?
    return if flagged?

    @revealed = true #unless revealed? || flagged?

    neighbors.each do |neighbor|
      neighbor.reveal unless neighbor.bombed? || flagged? || neighbor_bomb_count > 0
    end

  end

  def neighbors
    all_possible = DELTAS.map do |delta|
      [delta.first + @pos.first, delta.last + @pos.last]
    end

    valid_neighbors = all_possible.select do |coordinates|
      coordinates.any? { |val| val < 0 || val > 8 } == false
    end

    valid_neighbors = valid_neighbors.map do |coordinates|
      board[coordinates]
    end

    valid_neighbors
  end

  def neighbor_bomb_count
    bomb_count = 0

    neighbors.each do |neighbor|
      bomb_count += 1 if neighbor.bombed?
    end

    bomb_count
  end

  def render
    if revealed?
      neighbor_bomb_count == 0 ? "_" : neighbor_bomb_count.to_s
    elsif flagged?
      "f"
    else
      "*"
    end
  end

  def bomb_render
    if bombed?
      "B"
    else
      "_"
    end
  end

end

class Board

  attr_accessor :board
  attr_reader :size, :bombs

  def self.default_board(size)
    Array.new(size) { Array.new(size) }
  end

  def [](coordinates)
    x, y = coordinates
    board[x][y]
  end
  #
  # def []=(coordinates, value)
  #   x, y = coordinates
  #   board[x][y] = value
  # end

  def initialize(size = 9, bombs = 10)
    @board = Board.default_board(size)
    @bombs = bombs
    @size = size
    create_board
    put_bomb
  end

  def create_board
    board.each_index do |x|
      board.each_index do |y|
        board[x][y] = Tile.new(self, [x,y])
      end
    end
  end

  def put_bomb
    current_bomb_count = 0

    while current_bomb_count < bombs
      x, y = rand(0..size-1), rand(0..size-1)
      if !board[x][y].bombed?
        board[x][y].bombed = true
        current_bomb_count += 1
      end
    end
  end

  def render
    print "  "; (0...size).each { |y| print "#{y.to_s} "}
    puts
    board.each_index do |x|
      print "#{x.to_s} "
      board.each_index do |y|
        print board[x][y].render + " "
      end
      puts
    end
  end

  def bomb_render
    board.each_index do |x|
      board.each_index do |y|
        print board[x][y].bomb_render + " "
      end
      puts
    end
  end

  def won?
    correct_flag_count = 0

    board.each_index do |x|
      board.each_index do |y|
        correct_flag_count += 1 if board[x][y].bombed? && board[x][y].flagged?
      end
    end

    correct_flag_count == bombs
  end
end

class Game
  attr_reader :board

  def initialize
    @board = start_game
    #byebug
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
        board[coordinates].flag
        #byebug
      end
      board.render
      if save?
        save
        puts "Game saved."
        return
      end
    end

    puts (board.won? ? "You won" : "You lose")

    board.bomb_render
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
# b.bomb_render
# #b.render
# b.board[5][5].reveal
# puts
# b.render
# b.board[0][0].reveal
# puts
# b.render
# b.board[1][1].reveal
# puts
# b.render
