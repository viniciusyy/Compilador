const std = @import("std");

pub fn main(init: std.process.Init) !void {
    //const gpa = init.gpa;
    const io = init.io;

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    defer stdout.flush();

    // _ = gpa;
    //_ = io;

    //try stdout.print("Olá mundo! \n", .{});
    //try stdout.flush();

    //   for (10..80) |i| {
    //       try stdout.print("{d} \n", .{i});
    //   }

    //   try stdout.flush();

}
