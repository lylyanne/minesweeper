class Board

  attr_accessor :board
  attr_reader :size, :bombs

  def [](coordinates)
    x, y = coordinates
    board[x][y]
  end

  def initialize(size = 9, bombs = 10)
    @board = Array.new(size) { Array.new(size) }
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
      unless board[x][y].bombed?
        board[x][y].bombed = true
        current_bomb_count += 1
      end
    end
  end

  def render(over = false)
    print "  "; (0...size).each { |y| print "#{y.to_s} "}
    puts
    board.each_index do |x|
      print "#{x.to_s} "
      board.each_index do |y|
        print board[x][y].render(over) + " "
      end
      puts
    end
  end

  def won? # should be able to win if only bombs are unrevealed
    correct_flag_count = 0
    unrevealed_count = 0

    board.each_index do |x|
      board.each_index do |y|
        unrevealed_count += 1 unless board[x][y].revealed? && !board[x][y].bombed?
        correct_flag_count += 1 if board[x][y].bombed? && board[x][y].flagged?
      end
    end

    correct_flag_count == bombs || unrevealed_count == bombs
  end
end
