package day6

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

example_data :: "./example/day6.txt"
input_data :: "./data/day6.txt"

/*Skipping Part 2 - not interested in writing another round of input parsing*/

main :: proc() {
  { /* example */
    lines := read_lines_from_file(example_data)
    result1 := solve1(lines[:])
    fmt.println("Example 1:", result1)
  }

  { /* real */
    lines := read_lines_from_file(input_data)
    result1 := solve1(lines[:])
    fmt.println("Real 1:", result1)
  }
}

Op :: enum {Add, Mul}

Calc :: struct {numbers: []i64, operation: Op}

solve1 :: proc(lines: []string) -> (result: i64) {
  calculations := parse_calculations(lines[:])
  for c in calculations {
    result += calculate(c)
  }
  return
}

calculate :: proc(calc: Calc) -> (result: i64) {
  switch calc.operation {
  case .Add: {
    result = 0
    for n in calc.numbers {
      result += n
    }
  }
  case .Mul: {
    result = 1
    for n in calc.numbers {
      result *= n
    }
  }
  }
  return
}

parse_calculations :: proc(lines: []string) -> []Calc {
  for &line in lines {
    line = tidy_whitespaces(line)
  }

  col_count := len(strings.split(lines[0], " "))
  row_count := len(lines)
  number_count := row_count - 1

  calculations := make([]Calc, col_count)
  for col_idx in 0..<col_count {
    calculations[col_idx].numbers = make([]i64, number_count)
    for row_idx in 0 ..< number_count {
      value := strings.split(lines[row_idx], " ")[col_idx]
      int_value, ok := strconv.parse_int(value)
      if !ok {panic("bad int parse")}
      calculations[col_idx].numbers[row_idx] = cast(i64)int_value
    }
    calculations[col_idx].operation = parse_op(strings.split(lines[number_count], " ")[col_idx])
  }
  
  return calculations
}

parse_op :: proc(s: string) -> Op {
  if s == "*" { return .Mul }
  if s == "+" { return .Add }
  panic("unexpected op")
}

tidy_whitespaces :: proc(s: string) -> string {
  result := strings.trim(s, " ")
  running := true
  for running {
    new_result, _ := strings.replace_all(result, "  ", " ")
    if new_result == result {
      running = false
    }
    result = new_result
  }
  return result
}

// returns view on file data, that's why it's not freed
// program is so shortlived, not fussed about the memory leak
read_lines_from_file :: proc(filename: string) -> (lines: [dynamic]string) {
  data, err := os.read_entire_file(filename, context.allocator)
  if err != nil {
    fatal("Failed to read file", filename)
  }

  line_start_idx := 0
  current_idx := 0
  for current_idx < len(data) {
    if data[current_idx] == '\n' {
      exclusive_end_idx := current_idx
      append(&lines, string(data[line_start_idx : exclusive_end_idx]))
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
