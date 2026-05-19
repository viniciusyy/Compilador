const std = @import("std");

pub const Config = struct {
    help: bool = false,
    version: bool = false,
};

pub fn configParser(args: []const [:0]const u8) !Config {
    var config = Config{};

    if (args.len == 1) {
        config.help = true;
        return config;
    }

    var i: usize = 1;

    std.debug.print("# de argumentos: {d}\n", .{args.len});

    while (i < args.len) : (i += 1) {
        const arg = args[i];

        std.debug.print("Arg [{d}] = {s}\n", .{ i, arg });

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            config.help = true;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            config.version = true;
        }
    }

    return config;
}