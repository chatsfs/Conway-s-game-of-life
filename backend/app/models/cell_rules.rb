class CellRules
  def self.next_state(alive, neighbor_count)
    return neighbor_count == 3 unless alive
    neighbor_count == 2 || neighbor_count == 3
  end
end
