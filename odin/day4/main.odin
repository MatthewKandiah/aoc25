package day4

import "core:fmt"
import "core:os"

example_path :: "./example/day4.txt"
input_path :: "./data/day4.txt"

main :: proc() {
  { // example
    result1 := solve_part1(example_path)
    fmt.println("example result 1:", result1)
    result2 := solve_part2(example_path)
    fmt.println("example result 2:", result2)
  }

  { // real data
    result1 := solve_part1(input_path)
    fmt.println("real result 1:", result1)
    result2 := solve_part2(input_path)
    fmt.println("real result 2:", result2)
  }
}

solve_part2 :: proc(path: string) -> (result: i64) {
  lines := read_lines_from_file(path)
  running := true

  for running {
    counts := count_neighbours(lines[:])
    removed_count := remove_rolls(lines[:], counts[:])
    result += removed_count
    if removed_count == 0 {
      running = false
    }
  }
  return
}

remove_rolls :: proc(lines: [][]u8, counts: [][]i32) -> (result: i64) {
  assert(len(lines) == len(counts))
  for line_idx in 0..<len(lines) {
    line := lines[line_idx]
    line_counts := counts[line_idx]
    assert(len(line) == len(line_counts))
    for idx in 0..<len(line) {
      count := line_counts[idx]
      if (count >= 0 && count < 4) {
	result += 1
	line[idx] = '-'
      }
    }
  }
  return
}

solve_part1 :: proc(path: string) -> (result: i64) {
  lines := read_lines_from_file(path)
  counts := count_neighbours(lines[:])
  for line in counts {
    for count in line {
      if count >= 0 && count < 4 {result += 1}
    }
  }
  return
}

count_neighbours :: proc(lines: [][]u8) -> (counts: [dynamic][]i32) {
  for line, line_idx in lines {
    count_data := make([]i32, len(line))
    append(&counts, count_data)
    for char, char_idx in line {
      if char != '@' {
	count_data[char_idx] = -1
	continue
      }
      
      count: i32 = 0
      has_left_neighbours := char_idx > 0
      has_right_neighbours := char_idx < len(line) - 1
      has_preceding_line := line_idx > 0
      has_following_line := line_idx < len(lines) - 1
      
      if has_preceding_line {
	neighbour_slice := lines[line_idx - 1]
	if has_left_neighbours && neighbour_slice[char_idx - 1] == '@' {
	  count += 1
	}
	if neighbour_slice[char_idx] == '@' {
	  count += 1
	}
	if has_right_neighbours && neighbour_slice[char_idx + 1] == '@' {
	  count += 1
	}
      }
      
      {
	neighbour_slice := line
	if has_left_neighbours && neighbour_slice[char_idx - 1] == '@' {
	  count += 1
	}
	if has_right_neighbours && neighbour_slice[char_idx + 1] == '@' {
	  count += 1
	}
      }

      if has_following_line {
	neighbour_slice := lines[line_idx + 1]
	if has_left_neighbours && neighbour_slice[char_idx - 1] == '@' {
	  count += 1
	}
	if neighbour_slice[char_idx] == '@' {
	  count += 1
	}
	if has_right_neighbours && neighbour_slice[char_idx + 1] == '@' {
	  count += 1
	}
      }

      count_data[char_idx] = count
    }
  }
  return
}

// returns view on file data, that's why it's not freed
// program is so shortlived, not fussed about the memory leak
read_lines_from_file :: proc(filename: string) -> (lines: [dynamic][]u8) {
  data, err := os.read_entire_file(filename, context.allocator)
  if err != nil {
    fatal("Failed to read file", filename)
  }

  line_start_idx := 0
  current_idx := 0
  for current_idx < len(data) {
    if data[current_idx] == '\n' {
      exclusive_end_idx := current_idx
      append(&lines, data[line_start_idx : exclusive_end_idx])
      line_start_idx = current_idx + 1
    }
    current_idx += 1
  }
  return
}

fatal :: proc(args: ..any) {
  fmt.eprintln("FATAL:", args)
  os.exit(1);
}
