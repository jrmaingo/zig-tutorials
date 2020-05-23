const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().outStream();

    var args = std.process.args();
    _ = args.skip(); // skip name of executable
    while (args.nextPosix()) |arg| {
        try stdout.print("{}", .{arg});
    }
    try stdout.writeByte('\n');
}
