class Tile
  DELTAS = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, 1],
    [1, 1],
    [1, 0],
    [1, -1],
    [0, -1]
  ]

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

  def toggle_flag
    flagged? ? self.flagged = false : self.flagged = true
  end

  def revealed?
    @revealed
  end

  def reveal
    return if revealed?
    return if flagged?

    @revealed = true

    unless neighbor_bomb_count > 0 || bombed? 
      neighbors.each do |neighbor|
        neighbor.reveal unless neighbor.bombed? || flagged?
      end
    end
  end

  def neighbors
    all_possible = DELTAS.map do |delta|
      [delta.first + @pos.first, delta.last + @pos.last]
    end

    valid_neighbors = all_possible.select do |coordinates|
      coordinates.any? { |val| val < 0 || val > 8 } == false
    end

    valid_neighbors.map do |coordinates|
      board[coordinates]
    end
  end

  def neighbor_bomb_count
    bomb_count = 0

    neighbors.each do |neighbor|
      bomb_count += 1 if neighbor.bombed?
    end

    bomb_count
  end

  def render(over)
    if revealed?
      if over && bombed?
        "B"
      else
        neighbor_bomb_count == 0 ? "_" : neighbor_bomb_count.to_s
      end
    elsif flagged?
      over && bombed? ? "B" : "f"
    else
      over && bombed? ? "B" : "*"
    end
  end
end
