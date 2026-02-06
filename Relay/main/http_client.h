#ifndef HTTP_CLIENT_H
#define HTTP_CLIENT_H

#include <stdbool.h>

// POST device state to backend
void http_post_device_state(const char *device_id, bool state, float current, float power);

// GET command from backend (returns true if successful)
bool http_get_device_command(const char *device_id, bool *out_state);

#endif // HTTP_CLIENT_H
