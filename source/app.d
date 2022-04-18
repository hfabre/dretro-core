import std.stdio;
import std.format;
import core.vararg;
import libretro;
import frame_buffer;
import color;
import rectangle;
import state;

FrameBuffer fb;
int[int] key_map;
static State app_state;

enum Speed = 1;
enum Key {
   up = 1,
   down = 2,
   left = 3,
   right = 4
}

extern (C):

// The actual logic

void retro_run() {
   process_input();
   normalize_state();
   fb.draw_rect(0, 0, fb.width, fb.height, black);
   fb.draw_rect(app_state.rect, grey);
   video_cb(fb.c_frame_buffer(), fb.width, fb.height, fb.pitch);
}

void normalize_state() {
   // Avoid drawing outside the framebuffer

   if (app_state.rect.x + app_state.rect.w > fb.width) {
      app_state.rect.x = fb.width - app_state.rect.w;
   }

   if (app_state.rect.y + app_state.rect.h > fb.height) {
      app_state.rect.y = fb.height - app_state.rect.h;
   }

   if (app_state.rect.x < 0) {
      app_state.rect.x = 0;
   }

   if (app_state.rect.y < 0) {
      app_state.rect.y = 0;
   }
}

void process_input() {
    input_poll_cb();

   foreach (retro_key, engine_key; key_map) {
      short value = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, retro_key);
      handle_input(engine_key, value != 0);
   }
}

void handle_input(int key, bool pressed) {
   if (pressed) {
      final switch (key) {
         case Key.up:
            app_state.rect.y -= Speed;
            break;
         case Key.down:
            app_state.rect.y += Speed;
            break;
         case Key.right:
            app_state.rect.x += Speed;
            break;
         case Key.left:
            app_state.rect.x -= Speed;
            break;
      }
   }
}

// Init libretro and game

void retro_init() {
   Rectangle rect = { x: 0, y: 0, w: 10, h: 10 };
   app_state = new State(rect);
   fb = new FrameBuffer(200, 170);
   key_map = [
      RETRO_DEVICE_ID_JOYPAD_UP: Key.up,
      RETRO_DEVICE_ID_JOYPAD_DOWN: Key.down,
      RETRO_DEVICE_ID_JOYPAD_LEFT: Key.left,
      RETRO_DEVICE_ID_JOYPAD_RIGHT: Key.right
   ];
}

void retro_deinit() {
   destroy(fb);
}

void retro_set_environment(retro_environment_t cb) {
   environ_cb = cb;
   bool allow_no_game = true;

   cb(RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME, &allow_no_game);

   if (cb(RETRO_ENVIRONMENT_GET_LOG_INTERFACE, &logging))
      log_cb = logging.log;
   else
      log_cb = &my_log;
}

void retro_get_system_av_info(retro_system_av_info* info) {
   info.geometry.base_width = fb.width;
   info.geometry.base_height = fb.height;
   info.geometry.max_width = fb.width;
   info.geometry.max_height = fb.height;
   info.geometry.aspect_ratio = 0.0f;

   retro_pixel_format pixel_format = retro_pixel_format.RETRO_PIXEL_FORMAT_XRGB8888;
   environ_cb(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, &pixel_format);
}

bool retro_load_game(const retro_game_info* info) {
   // Use a format where one pixel is composed by 4 bytes (A - R - G - B each of them is 1 byte)
   retro_pixel_format fmt = retro_pixel_format.RETRO_PIXEL_FORMAT_XRGB8888;
   if (!environ_cb(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, &fmt))
   {
      log_cb(retro_log_level.RETRO_LOG_INFO, "XRGB8888 is not supported.\n");
      return false;
   }

   return true;
}

// Custom callbacks

void my_log(retro_log_level level, const char* fmt, ...) {
   va_list args;
   va_start(args, fmt);
   vprintf(fmt, args);
   va_end(args);
}

// Set callbacks

static retro_log_callback logging;
static retro_log_printf_t log_cb;
static retro_environment_t environ_cb;
static retro_video_refresh_t video_cb;
static retro_audio_sample_t audio_cb;
static retro_audio_sample_batch_t audio_batch_cb;
static retro_input_poll_t input_poll_cb;
static retro_input_state_t input_state_cb;

void retro_set_audio_sample(retro_audio_sample_t cb) {
   audio_cb = cb;
}

void retro_set_audio_sample_batch(retro_audio_sample_batch_t cb) {
   audio_batch_cb = cb;
}

void retro_set_input_poll(retro_input_poll_t cb) {
   input_poll_cb = cb;
}

void retro_set_input_state(retro_input_state_t cb) {
   input_state_cb = cb;
}

void retro_set_video_refresh(retro_video_refresh_t cb) {
   video_cb = cb;
}

// Mandatory symbols

uint retro_api_version() {
   return RETRO_API_VERSION;
}

void retro_get_system_info(retro_system_info* info) {
   info.library_name = "dretro-core";
   info.library_version = "0.1";
   info.need_fullpath = true;
   info.valid_extensions = "";
}

void retro_set_controller_port_device(uint port, uint device) {
   log_cb(retro_log_level.RETRO_LOG_INFO, "Plugging device %u into port %u.\n", device, port);
}

void retro_reset() {

}

static void audio_callback() {

}

static void audio_set_state(bool enable) {

}

void retro_unload_game() {

}

uint retro_get_region() {
   return RETRO_REGION_NTSC;
}

bool retro_load_game_special(uint type, const retro_game_info* info, size_t num) {
   return false;
}

size_t retro_serialize_size() {
   return 0;
}

bool retro_serialize(void* data_, size_t size) {
   return false;
}

bool retro_unserialize(const void* data_, size_t size) {
   return false;
}

void* retro_get_memory_data(uint id) {
   return null;
}

size_t retro_get_memory_size(uint id) {
   return 0;
}

void retro_cheat_reset() {

}

void retro_cheat_set(uint index, bool enabled, const char* code) {

}
