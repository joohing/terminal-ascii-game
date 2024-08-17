pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
});

const constants = @import("helpers").constants;
const std = @import("std");
const SDL_WINDOW_HEIGHT: u32 = 2000;
const SDL_WINDOW_WIDTH: u32 = 2000;
// const WINDOW_WIDTH: usize = 211;
// const WINDOW_HEIGHT: usize = 52;

// pub const InputBuffer = struct {
//     buf: [256]u8 = undefined,
//     ptr: u8 = 0,
//     mutex: std.Thread.Mutex,
// };

// pub const InputBuffer = struct {
//     buf: [256]u8 = undefined,
//     ptr: u8=0,
// };
const ReadEventError = error{
    QuitWasPressed,
};
pub const GameDisplay = struct {
    // stdin_buffer: InputBuffer,
    stdin: std.fs.File,
    stdout: std.fs.File,
    win: *c.SDL_Window,
    font: *c.TTF_Font,
    font_color: c.SDL_Color,
    renderer: *c.SDL_Renderer,

    pub fn init() !GameDisplay {
        _ = c.SDL_Init(c.SDL_INIT_VIDEO);
        _ = c.TTF_Init();
        _ = c.SDL_SetHint(c.SDL_HINT_RENDER_DRIVER, "opengl");
        const font: *c.TTF_Font = c.TTF_OpenFont("assets/fonts/NaturalMono-Regular.ttf", 100) orelse sdl_panic("Loading font");
        const font_color: c.SDL_Color = .{ .r = 255, .g = 255, .b = 255 };
        const win = c.SDL_CreateWindow("Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, SDL_WINDOW_WIDTH, SDL_WINDOW_HEIGHT, 0) orelse sdl_panic("Creating window");
        const renderer = c.SDL_CreateRenderer(win, 0, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse sdl_panic("Creating renderer");
        return GameDisplay{
            .stdin = undefined,
            .stdout = std.io.getStdOut(),
            .win = win,
            .font_color = font_color,
            .font = font,
            .renderer = renderer,
        };
    }

    // pub fn start_stdin_reading_thread(self: *GameDisplay) !void {
    //     _ = try std.Thread.spawn(.{}, read_stdin_thread, .{&self.stdin_buffer});
    // }

    pub fn display_buffer(self: *GameDisplay, buffer: []const u8) !void {
        // try self.clear_display();
        // try self.disable_echo();

        if (c.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 255) != 0) sdl_panic("Setting render draw color");
        if (c.SDL_RenderFillRect(self.renderer, &.{ .x = 0, .y = 0, .w = SDL_WINDOW_WIDTH, .h = SDL_WINDOW_HEIGHT }) != 0) sdl_panic("Filling rect with color");

        const row_count = constants.WINDOW_HEIGHT;

        var start_timer = try std.time.Timer.start();
        for (0..row_count) |row| {
            const start = row * constants.WINDOW_WIDTH;
            const end = (row + 1) * constants.WINDOW_WIDTH;
            try self.display_text(buffer[start..end], @intCast(row), row_count);
        }
        std.debug.print("Time to display everything {}\n", .{std.fmt.fmtDuration(start_timer.read())});

        // std.debug.print("{}", .{buffer[0]});
        // const arr_size = constants.WINDOW_HEIGHT * constants.WINDOW_WIDTH + 1;
        // var c_str: [arr_size:0]u8 = .{0} ** (arr_size);
        // std.mem.copyForwards(u8, &c_str, buffer[0..100]);
        // const surface = c.TTF_RenderText_Solid(self.font, &c_str, self.font_color, 0) orelse ttf_panic("Rendering text");

        // const texture: *c.SDL_Texture = c.SDL_CreateTextureFromSurface(self.renderer, surface) orelse sdl_panic("Creating texture from surface");
        // const dest_rect: c.SDL_Rect = .{ .x = 0, .y = 0, .w = 1000, .h = 1000 }; //create a rect

        // c.SDL_FreeSurface(surface);

        // _ = try self.stdout.writer().print("Input buffer: {s}", .{self.stdin_buffer.buf[0..self.stdin_buffer.ptr]});
        c.SDL_RenderPresent(self.renderer);
    }

    fn display_text(self: *GameDisplay, line: []const u8, line_index: u32, total_lines: u32) !void {
        const height = SDL_WINDOW_HEIGHT / total_lines;

        const arr_size = constants.WINDOW_HEIGHT * constants.WINDOW_WIDTH + 1;
        var c_str: [arr_size:0]u8 = .{0} ** (arr_size);

        std.mem.copyForwards(u8, &c_str, line);
        const surface = c.TTF_RenderText_Solid(self.font, &c_str, self.font_color) orelse ttf_panic("Rendering text");

        const dest_rect: c.SDL_Rect = .{ .x = 0, .y = @intCast(line_index * height), .w = SDL_WINDOW_WIDTH, .h = @intCast(height) }; //create a rect

        const texture: *c.SDL_Texture = c.SDL_CreateTextureFromSurface(self.renderer, surface) orelse sdl_panic("Creating texture from surface");
        const render_result = c.SDL_RenderCopy(self.renderer, texture, null, &dest_rect);
        if (render_result != 0) {
            sdl_panic("Copying from renderer");
        }
        c.SDL_DestroyTexture(texture);
        c.SDL_FreeSurface(surface);
    }

    fn hide_cursor(self: *GameDisplay) !void {
        try self.stdout.writer().print("\x1B[?25l\n", .{});
    }
    fn show_cursor(self: *GameDisplay) !void {
        _ = try self.stdout.writer().print("\x1B[?25h\n", .{});
    }
    fn clear_display(self: *GameDisplay) !void {
        _ = try self.stdout.writer().print("\x1B[2J\n", .{});
    }

    fn disable_echo(self: *GameDisplay) !void {
        _ = try self.stdout.writer().print("\x1B[12h\n", .{});
    }
};

pub fn read_events(input_buffer: []u32) ReadEventError!u32 {
    // Reads all events during this frame to the given buffer.
    // Returns the number of events read.
    // Returns an error if Quit was pressed.

    var event: c.SDL_Event = undefined;

    var ptr: u8 = 0;
    while (c.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            c.SDL_QUIT => {
                return ReadEventError.QuitWasPressed;
            },
            c.SDL_KEYDOWN => {
                input_buffer[ptr] = event.key.keysym.scancode;
                ptr += 1;
            },
            else => {

                // for now we only care about key downs. In the future we might support different events.
            },
        }
    }

    return ptr;
}

fn ttf_panic(base_msg: []const u8) noreturn {
    std.debug.print("TTF panic detected.\n", .{});
    const message = c.TTF_GetError() orelse @panic("Unknown error in TTF.");

    var ptr: u32 = 0;
    char_loop: while (true) {
        const char = message[ptr];
        if (char == 0) {
            break :char_loop;
        }
        ptr += 1;
    }
    var zig_slice: []const u8 = undefined;
    zig_slice.len = ptr;
    zig_slice.ptr = message;
    std.debug.print("{}: {any}", .{ ptr, message });

    var full_msg: [256]u8 = undefined;
    join_strs(base_msg, zig_slice, &full_msg);

    @panic(&full_msg);
}
fn sdl_panic(base_msg: []const u8) noreturn {
    std.debug.print("SDL panic detected.\n", .{});
    const message = c.SDL_GetError() orelse @panic("Unknown error in SDL.");

    var ptr: u32 = 0;
    char_loop: while (true) {
        const char = message[ptr];
        if (char == 0) {
            break :char_loop;
        }
        ptr += 1;
    }
    var zig_slice: []const u8 = undefined;
    zig_slice.len = ptr;
    zig_slice.ptr = message;

    var full_msg: [256]u8 = undefined;
    join_strs(base_msg, zig_slice, &full_msg);

    @panic(&full_msg);
}

fn join_strs(s1: []const u8, s2: []const u8, buf: []u8) void {
    for (s1, 0..) |char, index| {
        buf[index] = char;
    }
    for (s2, 0..) |char, index| {
        buf[s1.len + index] = char;
    }
}
