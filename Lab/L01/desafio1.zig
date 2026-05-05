const std = @import("std");

const print = std.debug.print;

const FILE1STD = "arquivo1.txt";
const FILE2STD = "arquivo2.txt";

fn imprimirArquivo(io: anytype, filename: []const u8) !void {
    const file = try std.Io.Dir.cwd().openFile(io, filename, .{});
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(io, &file_buffer);

    var line_no: usize = 0;

    print("\n===== Imprimindo arquivo: {s} =====\n", .{filename});

    while (try reader.interface.takeDelimiter('\n')) |line| {
        line_no += 1;
        print("{d}--{s}\n", .{ line_no, line });
    }

    print("Total lines: {d}\n", .{line_no});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const arquivo1 = if (args.len >= 2) args[1] else FILE1STD;
    const arquivo2 = if (args.len >= 3) args[2] else FILE2STD;

    try imprimirArquivo(io, arquivo1);
    try imprimirArquivo(io, arquivo2);
}
