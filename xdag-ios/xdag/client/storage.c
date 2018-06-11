/* локальное хранилище, T13.663-T13.825 $DVS:time$ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>
#include "storage.h"
#include "log.h"
#include "xdagmain.h"
#include "hash.h"

#if defined(_WIN32) || defined(_WIN64)
#define SLASH "\\"
#else
#define SLASH "/"
#endif

#if defined(ANDROID) || defined(__ANDROID__)
#define STORAGE_DIR0            "/sdcard/xdag/storage%s"
#else
#define STORAGE_DIR0            "storage%s"
#endif

#define STORAGE_DIR0_ARGS(t)    (g_xdag_testnet ? "-testnet" : "")
#define STORAGE_DIR1            STORAGE_DIR0 SLASH "%02x"
#define STORAGE_DIR1_ARGS(t)    STORAGE_DIR0_ARGS(t), (int)((t) >> 40)
#define STORAGE_DIR2            STORAGE_DIR1 SLASH "%02x"
#define STORAGE_DIR2_ARGS(t)    STORAGE_DIR1_ARGS(t), (int)((t) >> 32) & 0xff
#define STORAGE_DIR3            STORAGE_DIR2 SLASH "%02x"
#define STORAGE_DIR3_ARGS(t)    STORAGE_DIR2_ARGS(t), (int)((t) >> 24) & 0xff
#define STORAGE_FILE            STORAGE_DIR3 SLASH "%02x.dat"
#define STORAGE_FILE_ARGS(t)    STORAGE_DIR3_ARGS(t), (int)((t) >> 16) & 0xff
#define SUMS_FILE               "sums.dat"

static pthread_mutex_t storage_mutex = PTHREAD_MUTEX_INITIALIZER;
static int in_adding_all = 0;

static int correct_storage_sum(const char *path, int pos, const struct xdag_storage_sum *sum, int add)
{
	struct xdag_storage_sum sums[256];
	FILE *f = fopen(path, "r+b");

	if (f) {
		if (fread(sums, sizeof(struct xdag_storage_sum), 256, f) != 256) {
			fclose(f);
            xdag_app_err("Storag: sums file %s corrupted", path);
            return -1;
		}
		rewind(f);
	} else {
		f = fopen(path, "wb");
		if (!f) {
            xdag_app_err("Storag: can't create file %s", path);
            return -1;
		}
		memset(sums, 0, sizeof(sums));
	}

	if (!add) {
		if (sums[pos].size == sum->size && sums[pos].sum == sum->sum) {
			fclose(f); return 0;
		}

		if (sums[pos].size || sums[pos].sum) {
			sums[pos].size = sums[pos].sum = 0;
            xdag_app_err("Storag: corrupted, sums file %s, pos %x", path, pos);
		}
	}

	sums[pos].size += sum->size;
	sums[pos].sum += sum->sum;
	
	if (fwrite(sums, sizeof(struct xdag_storage_sum), 256, f) != 256) {
		fclose(f);
        xdag_app_err("Storag: can't write file %s", path);
        return -1;
	}
	
	fclose(f);
	
	return 1;
}

static int correct_storage_sums(xdag_time_t t, const struct xdag_storage_sum *sum, int add)
{
	char path[256];
	int res;

	sprintf(path, STORAGE_DIR3 SLASH SUMS_FILE, STORAGE_DIR3_ARGS(t));
	res = correct_storage_sum(path, (t >> 16) & 0xff, sum, add);
	if (res <= 0) return res;
	
	sprintf(path, STORAGE_DIR2 SLASH SUMS_FILE, STORAGE_DIR2_ARGS(t));
	res = correct_storage_sum(path, (t >> 24) & 0xff, sum, 1);
	if (res <= 0) return res;
	
	sprintf(path, STORAGE_DIR1 SLASH SUMS_FILE, STORAGE_DIR1_ARGS(t));
	res = correct_storage_sum(path, (t >> 32) & 0xff, sum, 1);
	if (res <= 0) return res;
	
	sprintf(path, STORAGE_DIR0 SLASH SUMS_FILE, STORAGE_DIR0_ARGS(t));
	res = correct_storage_sum(path, (t >> 40) & 0xff, sum, 1);
	if (res <= 0) return res;
	
	return 0;
}

/* Saves the block to local storage, returns its number or -1 in case of error */
int64_t xdag_storage_save(const struct xdag_block *b)
{
	struct xdag_storage_sum s;
	char path[256];
	FILE *f;
	int64_t res;
	int j;

	if (in_adding_all) return -1;
	
	sprintf(path, STORAGE_DIR0, STORAGE_DIR0_ARGS(b->field[0].time));
	xdag_mkdir(path);
	
	sprintf(path, STORAGE_DIR1, STORAGE_DIR1_ARGS(b->field[0].time));
	xdag_mkdir(path);
	
	sprintf(path, STORAGE_DIR2, STORAGE_DIR2_ARGS(b->field[0].time));
	xdag_mkdir(path);
	
	sprintf(path, STORAGE_DIR3, STORAGE_DIR3_ARGS(b->field[0].time));
	xdag_mkdir(path);
	
	sprintf(path, STORAGE_FILE, STORAGE_FILE_ARGS(b->field[0].time));
	
	pthread_mutex_lock(&storage_mutex);
	
	f = fopen(path, "ab");
	if (f) {
		fseek(f, 0, SEEK_END);
		res = ftell(f);
		fwrite(b, sizeof(struct xdag_block), 1, f);
		fclose(f);
		s.size = sizeof(struct xdag_block);
		s.sum = 0;

		for (j = 0; j < sizeof(struct xdag_block) / sizeof(uint64_t); ++j) {
			s.sum += ((uint64_t*)b)[j];
		}

		if (correct_storage_sums(b->field[0].time, &s, 1)) res = -1;
	} else res = -1;

	pthread_mutex_unlock(&storage_mutex);
	
	return res;
}

/* reads a block and its number from the local repository; writes it to the buffer or returns a permanent reference, 0 in case of error */
struct xdag_block *xdag_storage_load(xdag_hash_t hash, xdag_time_t time, uint64_t pos,
											   struct xdag_block *buf)
{
	xdag_hash_t hash0;
	char path[256];
	FILE *f;

	sprintf(path, STORAGE_FILE, STORAGE_FILE_ARGS(time));

	pthread_mutex_lock(&storage_mutex);
	
	f = fopen(path, "rb");
	if (f) {
		if (fseek(f, pos, SEEK_SET) < 0 || fread(buf, sizeof(struct xdag_block), 1, f) != 1) buf = 0;
		fclose(f);
	} else {
		buf = 0;
	}

	pthread_mutex_unlock(&storage_mutex);
	
	if (buf) {
		xdag_hash(buf, sizeof(struct xdag_block), hash0);
		if (memcmp(hash, hash0, sizeof(xdag_hashlow_t))) buf = 0;
	}

	if (!buf)
		xdag_blocks_reset();

	return buf;
}
#if defined(ANDROID) || defined(__ANDROID__)
#define bufsize (1024)
#else
#define bufsize (0x100000 / sizeof(struct xdag_block))
#endif
static int sort_callback(const void *l, const void *r)
{
	struct xdag_block **L = (struct xdag_block **)l, **R = (struct xdag_block **)r;

	if ((*L)->field[0].time < (*R)->field[0].time) return -1;
	if ((*L)->field[0].time > (*R)->field[0].time) return 1;

	return 0;
}

uint64_t xdag_load_blocks_x(xdag_time_t start_time, xdag_time_t end_time, void *data, void *(*callback)(void *, void *)){

	xdag_app_debug("xdag_load_blocks_x start_time %llu end_time %llu data %p callback %p",
                   start_time,end_time,data,callback);

	uint64_t res = xdag_load_blocks(start_time,end_time,data,callback);

	return res;
}

/* Calls a callback for all blocks from the repository that are in specified time interval; returns the number of blocks */
uint64_t xdag_load_blocks(xdag_time_t start_time, xdag_time_t end_time, void *data, void *(*callback)(void *, void *))
{
    xdag_app_debug("start load blocks");
    struct xdag_block buf[bufsize], *pbuf[bufsize];
	struct xdag_storage_sum s;
	char path[256];
	struct stat st;
	FILE *f;
	uint64_t sum = 0, pos = 0, pos0, mask;
	int64_t i, j, k, todo;
	s.size = s.sum = 0;

	while (start_time < end_time) {
		sprintf(path, STORAGE_FILE, STORAGE_FILE_ARGS(start_time));
		xdag_app_debug("load storage file path %s",path);
		pthread_mutex_lock(&storage_mutex);
		f = fopen(path, "rb");
		if (f) {
			if (fseek(f, pos, SEEK_SET) < 0)
                todo = 0;
			else
                todo = fread(buf, sizeof(struct xdag_block), bufsize, f);
			fclose(f);
		} else {
            xdag_app_err("laod storage file %s failed error %s",path,strerror(errno));
			todo = 0;
		}
		pthread_mutex_unlock(&storage_mutex);

		pos0 = pos;

		for (i = k = 0; i < todo; ++i, pos += sizeof(struct xdag_block)) {

			if (buf[i].field[0].time >= start_time && buf[i].field[0].time < end_time) {
				s.size += sizeof(struct xdag_block);

				for (j = 0; j < sizeof(struct xdag_block) / sizeof(uint64_t); ++j) {
					s.sum += ((uint64_t*)(buf + i))[j];
				}

				pbuf[k++] = buf + i;
			}
		}

		if (k) {
			qsort(pbuf, k, sizeof(struct xdag_block *), sort_callback);
		}

		for (i = 0; i < k; ++i) {
			pbuf[i]->field[0].transport_header = pos0 + ((uint8_t*)pbuf[i] - (uint8_t*)buf);
			if (callback(pbuf[i], data)) return sum;
			sum++;
		}

		if (todo != bufsize) {
			if (f) {
				int res;

				pthread_mutex_lock(&storage_mutex);

				res = correct_storage_sums(start_time, &s, 0);

				pthread_mutex_unlock(&storage_mutex);

				if (res) break;

				s.size = s.sum = 0;
				mask = (1l << 16) - 1;
			} else if (sprintf(path, STORAGE_DIR3, STORAGE_DIR3_ARGS(start_time)), !stat(path, &st)) {
				mask = (1l << 16) - 1;
			} else if (sprintf(path, STORAGE_DIR2, STORAGE_DIR2_ARGS(start_time)), !stat(path, &st)) {
				mask = (1l << 24) - 1;
			} else if (sprintf(path, STORAGE_DIR1, STORAGE_DIR1_ARGS(start_time)), !stat(path, &st)) {
				mask = (1ll << 32) - 1;
			} else {
				mask = (1ll << 40) - 1;
			}

			start_time |= mask;
			start_time++;

			pos = 0;
		}
	}

	return sum;
}

/* places the sums of blocks in 'sums' array, blocks are filtered by interval from start_time to end_time, splitted to 16 parts;
 * end - start should be in form 16^k
 * (original russian comment is unclear too) */
int xdag_load_sums(xdag_time_t start_time, xdag_time_t end_time, struct xdag_storage_sum sums[16])
{
	struct xdag_storage_sum buf[256];
	char path[256];
	FILE *f;
	int i, level;

	end_time -= start_time;
	if (!end_time || end_time & (end_time - 1) || end_time & 0xFFFEEEEEEEEFFFFFl) return -1;

	for (level = -6; end_time; level++, end_time >>= 4);

	if (level < 2) {
		sprintf(path, STORAGE_DIR3 SLASH SUMS_FILE, STORAGE_DIR3_ARGS(start_time & 0xffffff000000l));
	} else if (level < 4) {
		sprintf(path, STORAGE_DIR2 SLASH SUMS_FILE, STORAGE_DIR2_ARGS(start_time & 0xffff00000000l));
	} else if (level < 6) {
		sprintf(path, STORAGE_DIR1 SLASH SUMS_FILE, STORAGE_DIR1_ARGS(start_time & 0xff0000000000l));
	} else {
		sprintf(path, STORAGE_DIR0 SLASH SUMS_FILE, STORAGE_DIR0_ARGS(start_time & 0x000000000000l));
	}

	f = fopen(path, "rb");
	if (f) {
		fread(buf, sizeof(struct xdag_storage_sum), 256, f); fclose(f);
	} else {
		memset(buf, 0, sizeof(buf));
	}

	if (level & 1) {
		memset(sums, 0, 16 * sizeof(struct xdag_storage_sum));

		for (i = 0; i < 256; ++i) {
			sums[i >> 4].size += buf[i].size, sums[i >> 4].sum += buf[i].sum;
		}
	} else {
		memcpy(sums, buf + (start_time >> ((level + 4) * 4) & 0xf0), 16 * sizeof(struct xdag_storage_sum));
	}

	return 1;
}

/* completes work with the storage */
void xdag_storage_finish(void)
{
	pthread_mutex_lock(&storage_mutex);
}

/* release the resource storage used while program exit */
void xdag_storage_uninit(void)
{
        //TODO: release the resource storage used

}
