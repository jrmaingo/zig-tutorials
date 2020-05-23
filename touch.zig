const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip(); // skip name of executable

    const flags = std.fs.File.CreateFlags{
        .truncate = false,
    };

    if (args.nextPosix()) |path| {
        const file = if (std.fs.path.isAbsolute(path))
            try std.fs.createFileAbsolute(path, flags)
        else
            try std.fs.cwd().createFile(path, flags);
        file.close();
    } else {
        std.debug.warn("error: expected a file name\n", .{});
    }
}
