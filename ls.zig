const std = @import("std");

// basic ls for cwd only

pub fn main() !void {
    const stdout = std.io.getStdOut().outStream();

    const args = std.fs.Dir.OpenDirOptions{
        .iterate = true,
    };
    const cwd = try std.fs.cwd().openDir(".", args);

    var entries = cwd.iterate();
    while (try entries.next()) |entry| {
        try stdout.print("{}\n", .{entry.name});
    }
}
