const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().outStream();
    const stdin = std.io.getStdIn().inStream();

    while (true) {
        const byte_read = stdin.readByte() catch |err| switch (err) {
            error.EndOfStream => return,
            else => unreachable,
        };
        try stdout.writeByte(byte_read);
    }
}
