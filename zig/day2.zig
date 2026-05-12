const std = @import("std");
const util = @import("./util.zig");

pub fn main(init: std.process.Init) !void {
    const example_file = try util.example_file(2);
    const input_file = try util.input_file(2);

    const io = init.io;
    const allocator = init.arena.allocator();

    std.debug.print("AoC25: Day2\n", .{});

    { // example
        std.debug.print("Reading example data from {s}\n", .{example_file});
        var example_data: std.ArrayList([]const u8) = .empty;
        try util.read_lines(io, allocator, example_file, &example_data);
        const result = try solve_part1(example_data.items[0]);
        std.debug.print("Part 1 example data: {d}\n", .{result});
        const result2 = try solve_part2(example_data.items[0]);
        std.debug.print("Part 2 example data: {d}\n", .{result2});
    }

    { // real
        std.debug.print("Reading real data from {s}\n", .{input_file});
        var input_data: std.ArrayList([]const u8) = .empty;
        try util.read_lines(io, allocator, input_file, &input_data);
        const result = try solve_part1(input_data.items[0]);
        std.debug.print("Part 1 real data: {d}\n", .{result});
        const result2 = try solve_part2(input_data.items[0]);
        std.debug.print("Part 2 real data: {d}\n", .{result2});
    }
}

fn solve_part1(data: []const u8) !u64 {
    var result: u64 = 0;
    const ranges = try parse_ranges(data);
    for (ranges) |range| {
        for (0..range.size() + 1) |i| {
            const val = range.start + i;
            if (try is_invalid(val)) {
                result += val;
            }
        }
    }
    return result;
}

fn solve_part2(data: []const u8) !u64 {
    var result: u64 = 0;
    const ranges = try parse_ranges(data);
    for (ranges) |range| {
        for (0..range.size() + 1) |i| {
            const val = range.start + i;
            if (try is_invalid_2(val)) {
                result += val;
            }
        }
    }
    return result;
}

fn is_invalid(n: u64) !bool {
    var buf: [1024]u8 = undefined;
    const digits = try std.fmt.bufPrint(&buf, "{d}", .{n});
    const sz = (digits.len + 1) / 2;
    const first = digits[0..sz];
    const second = digits[sz..];
    return std.mem.eql(u8, first, second);
}

fn is_invalid_2(n: u64) !bool {
    var buf: [1024]u8 = undefined;
    const digits = try std.fmt.bufPrint(&buf, "{d}", .{n});
    for (1..1 + (digits.len / 2)) |sz| {
        if (digits.len % sz != 0) {
            // skip window sizes that don't exactly subdivide the string
            continue;
        }
        const last = digits[digits.len - sz ..];
        var all_match = true;
        for (0..digits.len / sz - 1) |x| {
            // compare each window of characters to the final window
            const cmp = digits[sz * x .. sz * (x + 1)];
            if (!std.mem.eql(u8, last, cmp)) {
                all_match = false;
                break;
            }
        }
        if (all_match) {
            return true;
        }
    }
    // no sz where all windows equal => is valid
    return false;
}

const Range = struct {
    start: usize,
    end: usize,

    const Self = @This();

    fn size(self: Self) usize {
        return @intCast(self.end - self.start);
    }
};

var range_buf: [4096]Range = undefined;
fn parse_ranges(data: []const u8) ![]Range {
    var it = std.mem.splitScalar(u8, data, ',');
    var cnt: usize = 0;

    while (it.next()) |range_str| {
        range_buf[cnt] = try parse_range(range_str);
        cnt += 1;
    }
    return range_buf[0..cnt];
}

fn parse_range(data: []const u8) !Range {
    var idx: usize = 0;
    for (data, 0..) |b, i| {
        if (b == '-') {
            idx = i;
            break;
        }
    }
    const start = try std.fmt.parseInt(u64, data[0..idx], 10);
    const end = try std.fmt.parseInt(u64, data[idx + 1 .. data.len], 10);
    return .{ .start = start, .end = end };
}
