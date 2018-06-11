/* dnet: communication with tap interface; T13.137-T13.137; $DVS:time$ */

#ifndef DNET_TAP_H_INCLUDED
#define DNET_TAP_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

/* открывает устройство tap с данным номером, возвращает файловый дескриптор */
extern int dnet_tap_open(int tap_number);

#ifdef __cplusplus
}
#endif

#endif
