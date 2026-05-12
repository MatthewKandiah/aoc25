const std = @import("std");
const util = @import("./util.zig");

pub fn main(init: std.process.Init) !void {
    const example_file = try util.example_file(1);
    const input_file = try util.input_file(1);

    const io = init.io;
    const allocator = init.arena.allocator();

    std.debug.print("AoC25: Day1\n", .{});

    {
        std.debug.print("Reading example data from {s}\n", .{example_file});
        var example_data: std.ArrayList([]const u8) = .empty;
        try util.read_lines(io, allocator, example_file, &example_data);
        const result = try solve_part1(example_data);
        std.debug.print("Part 1 example data: {d}\n", .{result});
        const result2 = try solve_part2(example_data);
        std.debug.print("Part 2 example data: {d}\n", .{result2});
    }

    {
        std.debug.print("Reading real data from {s}\n", .{input_file});
        var input_data: std.ArrayList([]const u8) = .empty;
        try util.read_lines(io, allocator, input_file, &input_data);
        const result = try solve_part1(input_data);
        std.debug.print("Part 1 real data: {d}\n", .{result});
        const result2 = try solve_part2(input_data);
        std.debug.print("Part 2 real data: {d}\n", .{result2});
    }
}

const Instruction = struct {
    is_right: bool,
    value: i32,
};

fn parse_line(line: []const u8) anyerror!Instruction {
    if (line[0] == 'R') {
        return .{ .is_right = true, .value = try std.fmt.parseInt(i32, line[1..], 10) };
    } else if (line[0] == 'L') {
        return .{ .is_right = false, .value = try std.fmt.parseInt(i32, line[1..], 10) };
    } else {
        return error.UnexpectedToken;
    }
}

const ApplyResult = struct {
    new_value: i32,
    zero_touch_count: i32,
};

fn apply_instruction(initial_value: i32, instruction: Instruction) ApplyResult {
    const sign: i32 = if (instruction.is_right) 1 else -1;
    var v = initial_value + (sign * instruction.value);
    var zero_touch_count: i32 = 0;
    while (v < 0) {
        v += 100;
        zero_touch_count += 1;
    }
    while (v >= 100) {
        v -= 100;
        zero_touch_count += 1;
    }
    return .{ .new_value = v, .zero_touch_count = zero_touch_count };
}

fn solve_part1(data: std.ArrayList([]const u8)) !i32 {
    var result: i32 = 0;
    var dial_value: i32 = 50;
    for (data.items) |line| {
        const instruction = try parse_line(line);
        dial_value = apply_instruction(dial_value, instruction).new_value;
        if (dial_value == 0) {
            result += 1;
        }
    }
    return result;
}

fn solve_part2(data: std.ArrayList([]const u8)) !i32 {
    var result: i32 = 0;
    var dial_value: i32 = 50;
    for (data.items) |line| {
        const instruction = try parse_line(line);
        const apply_result = apply_instruction(dial_value, instruction);
        dial_value = apply_result.new_value;
        result += apply_result.zero_touch_count;
    }
    return result;
}
