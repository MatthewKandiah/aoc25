package day5

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:sort"

example_path :: "./example/day5.txt"
input_path :: "./data/day5.txt"

main :: proc() {
  { /* example */
    lines := read_lines_from_file(example_path)
    ranges, values := parse_lines(lines[:])
    result1 := solve1(ranges[:], values[:])
    fmt.println("Example part 1:", result1)
    result2 := solve2(ranges[:])
    fmt.println("Example part 2:", result2)
  }

  { /* real */
    lines := read_lines_from_file(input_path)
    ranges, values := parse_lines(lines[:])
    result1 := solve1(ranges[:], values[:])
    fmt.println("Real part 1:", result1)
    result2 := solve2(ranges[:])
    fmt.println("Real part 2:", result2)
  }
}

solve2 :: proc(ranges: []Range) -> (result: i64) {
  sort_ranges(ranges)
  highest_value_seen: i64= 0
  for range in ranges {
    low := max(range.start, highest_value_seen + 1)
    high := range.end
    if low <= high {
      count := high - low + 1
      result += count
      highest_value_seen = max(highest_value_seen, range.end)
    }
  }
  return
}

sort_ranges :: proc(ranges: []Range) {
  sort.quick_sort_proc(ranges, range_comp)
}

range_comp :: proc(left: Range, right: Range) -> int {
  return cast(int)(left.start - right.start)
}

solve1 :: proc(ranges: []Range, values: []i64) -> (result: i64) {
  for value in values {
    found := false
    for range in ranges {
      if range_contains(range, value) {
	found = true
      }
    }
    if found {
      result += 1
    }
  }
  return
}

Range :: struct {
  start: i64,
  end: i64,
}

range_contains :: proc(r: Range, val: i64) -> bool {
  return val >= r.start && val <= r.end
}

Mode :: enum {Range, Value}

parse_lines :: proc(lines: [][]u8) -> (ranges: [dynamic]Range, values: [dynamic]i64) {
  seeking := Mode.Range
  for line in lines {
    if len(line) == 0 {
      seeking = Mode.Value
      continue
    }
    
    switch seeking {
    case .Range:
      append(&ranges, parse_range(line))
    case .Value:
      append(&values, parse_int(line))
    }
  }
  return
}

parse_range :: proc(line: []u8) -> Range {
  hyphen_index := find_hyphen(line)
  return Range{
    start = parse_int(line[0:hyphen_index]),
    end = parse_int(line[hyphen_index+1:]),
  }
}

find_hyphen :: proc(chars: []u8) -> int {
  for c, i in chars {
    if c == '-' { return i }
  }
  panic("Failed to find hyphen")
}

parse_int :: proc(chars: []u8) -> i64 {
  value, _ := strconv.parse_int(string(chars))
  return cast(i64)value
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
