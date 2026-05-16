const std = @import("std");
const util = @import("./util.zig");

pub fn main(init: std.process.Init) !void {
    const example_file = try util.example_file(3);
    const input_file = try util.input_file(3);

    const io = init.io;
    const allocator = init.arena.allocator();

    std.debug.print("AoC25: Day3\n", .{});

    { // example
        std.debug.print("Reading example data from {s}\n", .{example_file});
        var example_data: std.ArrayList([]const u8) = .empty;
        try util.read_lines(io, allocator, example_file, &example_data);
        const result = try solve_part1(example_data);
        std.debug.print("Part 1 example data: {d}\n", .{result});
        const result2 = try solve_part2(example_data);
        std.debug.print("Part 2 example data: {d}\n", .{result2});
    }

    { // real
        std.debug.print("Reading real data from {s}\n", .{input_file});
        var input_data: std.ArrayList([]const u8) = .empty;
        try util.read_lines(io, allocator, input_file, &input_data);
        const result = try solve_part1(input_data);
        std.debug.print("Part 1 real data: {d}\n", .{result});
        const result2 = try solve_part2(input_data);
        std.debug.print("Part 2 real data: {d}\n", .{result2});
    }
}

fn solve_part2(data: std.ArrayList([]const u8)) !i64 {
    var result: i64 = 0;
    for (data.items) |bank| {
        var picked_idxs = [1]usize{0} ** 12;
        var picked_count: usize = 0;
        var highest_picked_idx: i32 = -1;
        while (picked_count < 12) {
            const required_following_chars = 11 - picked_count;
            const low: usize = @intCast(highest_picked_idx + 1);
            const high: usize = bank.len - required_following_chars;
            const possible_next_chars = bank[low..high];
            picked_idxs[picked_count] = low + try pick_idx(possible_next_chars);
            highest_picked_idx = @intCast(picked_idxs[picked_count]);
            picked_count += 1;
        }
        const value = indices_to_value(picked_idxs[0..], bank);
        result += value;
    }
    return result;
}

fn indices_to_value(indices: []const usize, chars: []const u8) i64 {
    var result: i64 = 0;
    for (indices) |idx| {
        const c = chars[idx];
        result = result * 10 + ascii_to_int(c);
    }
    return result;
}

fn pick_idx(chars: []const u8) !usize {
    var desired_value: u8 = '9';
    while (desired_value >= '0') {
        for (chars, 0..) |c, i| {
            if (c == desired_value) {
                return i;
            }
        }
        desired_value -= 1;
    }
    return error.Fubar;
}

fn ascii_to_int(c: u8) i32 {
    return c - '0';
}

fn solve_part1(data: std.ArrayList([]const u8)) !i64 {
    var result: i32 = 0;
    for (data.items) |bank| {
        var first_appears = [10]i32{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
        var last_appears = [10]i32{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
        for (bank, 0..) |c, i| {
            switch (c) {
                '0'...'9' => update(c - '0', i, &first_appears, &last_appears),
                else => return error.FuckedItUp,
            }
        }
        result += try get_largest_number(&first_appears, &last_appears, @intCast(bank.len));
    }
    return result;
}

fn update(val: usize, i: usize, first_appears: []i32, last_appears: []i32) void {
    if (first_appears[val] == -1) {
        first_appears[val] = @intCast(i);
    }
    last_appears[val] = @intCast(i);
}

fn get_largest_number(first_appears: []i32, last_appears: []i32, number_of_digits: i32) !i32 {
    std.debug.assert(first_appears.len == 10);
    std.debug.assert(last_appears.len == 10);

    var largest_digit: i32 = -1;
    for (0..10) |i| {
        const test_val = 9 - i;
        if (first_appears[test_val] != -1) {
            largest_digit = @intCast(test_val);
            break;
        }
    }

    const unsigned_largest_digit: usize = @intCast(largest_digit);
    var second_largest_digit: i32 = -1;
    for (1..unsigned_largest_digit + 1) |i| {
        const test_val = unsigned_largest_digit - i;
        if (first_appears[test_val] != -1) {
            second_largest_digit = @intCast(test_val);
            break;
        }
    }

    if (first_appears[unsigned_largest_digit] == number_of_digits - 1) {
        // largest digit first appears in last place
        return second_largest_digit * 10 + largest_digit;
    }

    for (0..10) |i| {
        // we know there's at least one digit after the first appearance of the largest digit, so take the largest digit that appears after that
        const test_idx = 9 - i;
        if (last_appears[test_idx] > first_appears[unsigned_largest_digit]) {
            return largest_digit * 10 + @as(i32, @intCast(test_idx));
        }
    }

    return error.GodDamnIt;
}
