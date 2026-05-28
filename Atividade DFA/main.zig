const std = @import("std");

const State = enum {
    start,

    // Decimal
    zero,
    dec_int,
    dot_start,
    dec_dot,
    dec_frac,
    dec_exp_start,
    dec_exp_sign,
    dec_exp_digits,

    // Hexadecimal
    hex_prefix,
    hex_int,
    hex_dot_no_digits,
    hex_dot,
    hex_frac,
    hex_exp_start,
    hex_exp_sign,
    hex_exp_digits,

    // Sufixo: f, F, l, L
    suffix,
};

fn isDecDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn isHexDigit(c: u8) bool {
    return isDecDigit(c) or
        (c >= 'a' and c <= 'f') or
        (c >= 'A' and c <= 'F');
}

fn isFloatSuffix(c: u8) bool {
    return switch (c) {
        'f', 'F', 'l', 'L' => true,
        else => false,
    };
}

fn isSign(c: u8) bool {
    return c == '+' or c == '-';
}

fn isAccepting(state: State) bool {
    return switch (state) {
        .dec_dot, .dec_frac, .dec_exp_digits, .hex_exp_digits, .suffix => true,
        else => false,
    };
}

fn step(state: State, c: u8) ?State {
    return switch (state) {
        .start => blk: {
            if (c == '.') break :blk .dot_start;
            if (c == '0') break :blk .zero;
            if (isDecDigit(c)) break :blk .dec_int;
            break :blk null;
        },

        // -------------------------
        // Parte decimal
        // -------------------------

        .zero => blk: {
            if (c == 'x' or c == 'X') break :blk .hex_prefix;
            if (c == '.') break :blk .dec_dot;
            if (c == 'e' or c == 'E') break :blk .dec_exp_start;
            if (isDecDigit(c)) break :blk .dec_int;
            break :blk null;
        },

        .dec_int => blk: {
            if (isDecDigit(c)) break :blk .dec_int;
            if (c == '.') break :blk .dec_dot;
            if (c == 'e' or c == 'E') break :blk .dec_exp_start;
            break :blk null;
        },

        .dot_start => blk: {
            if (isDecDigit(c)) break :blk .dec_frac;
            break :blk null;
        },

        .dec_dot => blk: {
            if (isDecDigit(c)) break :blk .dec_frac;
            if (c == 'e' or c == 'E') break :blk .dec_exp_start;
            if (isFloatSuffix(c)) break :blk .suffix;
            break :blk null;
        },

        .dec_frac => blk: {
            if (isDecDigit(c)) break :blk .dec_frac;
            if (c == 'e' or c == 'E') break :blk .dec_exp_start;
            if (isFloatSuffix(c)) break :blk .suffix;
            break :blk null;
        },

        .dec_exp_start => blk: {
            if (isSign(c)) break :blk .dec_exp_sign;
            if (isDecDigit(c)) break :blk .dec_exp_digits;
            break :blk null;
        },

        .dec_exp_sign => blk: {
            if (isDecDigit(c)) break :blk .dec_exp_digits;
            break :blk null;
        },

        .dec_exp_digits => blk: {
            if (isDecDigit(c)) break :blk .dec_exp_digits;
            if (isFloatSuffix(c)) break :blk .suffix;
            break :blk null;
        },

        // -------------------------
        // Parte hexadecimal
        // Exemplos válidos:
        // 0x1p10
        // 0x1.8p+2
        // 0x.8p-1
        // -------------------------

        .hex_prefix => blk: {
            if (isHexDigit(c)) break :blk .hex_int;
            if (c == '.') break :blk .hex_dot_no_digits;
            break :blk null;
        },

        .hex_int => blk: {
            if (isHexDigit(c)) break :blk .hex_int;
            if (c == '.') break :blk .hex_dot;
            if (c == 'p' or c == 'P') break :blk .hex_exp_start;
            break :blk null;
        },

        .hex_dot_no_digits => blk: {
            if (isHexDigit(c)) break :blk .hex_frac;
            break :blk null;
        },

        .hex_dot => blk: {
            if (isHexDigit(c)) break :blk .hex_frac;
            if (c == 'p' or c == 'P') break :blk .hex_exp_start;
            break :blk null;
        },

        .hex_frac => blk: {
            if (isHexDigit(c)) break :blk .hex_frac;
            if (c == 'p' or c == 'P') break :blk .hex_exp_start;
            break :blk null;
        },

        .hex_exp_start => blk: {
            if (isSign(c)) break :blk .hex_exp_sign;
            if (isDecDigit(c)) break :blk .hex_exp_digits;
            break :blk null;
        },

        .hex_exp_sign => blk: {
            if (isDecDigit(c)) break :blk .hex_exp_digits;
            break :blk null;
        },

        .hex_exp_digits => blk: {
            if (isDecDigit(c)) break :blk .hex_exp_digits;
            if (isFloatSuffix(c)) break :blk .suffix;
            break :blk null;
        },

        .suffix => null,
    };
}

pub fn scanFloat(input: []const u8) ?usize {
    var state: State = .start;
    var i: usize = 0;
    var last_accept: ?usize = null;

    while (i < input.len) {
        const next_state = step(state, input[i]) orelse break;

        state = next_state;
        i += 1;

        if (isAccepting(state)) {
            last_accept = i;
        }
    }

    return last_accept;
}

pub fn isFloatLiteral(input: []const u8) bool {
    const len = scanFloat(input) orelse return false;
    return len == input.len;
}

pub fn main() void {
    const tests = [_][]const u8{
        "1.0",
        ".5",
        "10.",
        "1e10",
        "1.5e-2",
        "1.0f",
        "1.0L",
        "123",
        "1e",
        ".",
        "0x1p10",
        "0x1.8p+2",
        "0x.8p-1",
        "0x1.8",
        "0x.p1",
        "0x1p",
        "abc",
    };

    for (tests) |t| {
        if (isFloatLiteral(t)) {
            std.debug.print("{s} -> FLOAT válido\n", .{t});
        } else {
            std.debug.print("{s} -> inválido como FLOAT\n", .{t});
        }
    }
}
