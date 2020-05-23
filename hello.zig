const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    const stdout = std.io.getStdOut().outStream();
    try stdout.print("Hello, {}!\n", .{"World"});
}
