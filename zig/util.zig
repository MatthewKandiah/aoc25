const std = @import("std");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub var example_file_buffer: [4096]u8 = undefined;
pub var input_file_buffer: [4096]u8 = undefined;

pub fn example_file(day: i32) ![]const u8 {
    return std.fmt.bufPrint(&example_file_buffer, "example/day{d}.txt", .{day});
}

pub fn input_file(day: i32) ![]const u8 {
    return std.fmt.bufPrint(&input_file_buffer, "data/day{d}.txt", .{day});
}

pub fn read_lines(io: Io, allocator: Allocator, filename: []const u8, array_list: *ArrayList([]const u8)) !void {
    const file = try Io.Dir.cwd().openFile(io, filename, .{});
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(io, &file_buffer);
    while (try reader.interface.takeDelimiter('\n')) |line| {
        const allocated_line = try allocator.alloc(u8, line.len);
        for (line, 0..) |c, idx| {
            allocated_line[idx] = c;
        }
        try array_list.append(allocator, allocated_line);
    }
}
