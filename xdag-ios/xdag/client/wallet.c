/* кошелёк, T13.681-T13.788 $DVS:time$ */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "crypt.h"
#include "wallet.h"
#include "log.h"
#include "xdagmain.h"
#include "transport.h"
#include "utils.h"

#define WALLET_FILE "wallet.dat"


struct key_internal {
	xdag_hash_t pub, priv;
	void *key;
	struct key_internal *prev;
	uint8_t pub_bit;
};

static struct key_internal *def_key = 0;
static struct xdag_public_key *keys_arr = 0;
static pthread_mutex_t wallet_mutex = PTHREAD_MUTEX_INITIALIZER;
int nkeys = 0, maxnkeys = 0;

static int add_key(xdag_hash_t priv)
{
	struct key_internal *k = malloc(sizeof(struct key_internal));

	if (!k) return -1;

	pthread_mutex_lock(&wallet_mutex);

	if (priv) {
		memcpy(k->priv, priv, sizeof(xdag_hash_t));
		k->key = xdag_private_to_key(k->priv, k->pub, &k->pub_bit);
	} else {
		FILE *f;
		uint32_t priv32[sizeof(xdag_hash_t) / sizeof(uint32_t)];

		k->key = xdag_create_key(k->priv, k->pub, &k->pub_bit);
		
//        f = fopen(WALLET_FILE, "ab");
        f = xdag_open_file(WALLET_FILE, "ab");
		if (!f) goto fail;
		
		memcpy(priv32, k->priv, sizeof(xdag_hash_t));
		
		xdag_user_crypt_action(priv32, nkeys, sizeof(xdag_hash_t) / sizeof(uint32_t), 1);
		
		if (fwrite(priv32, sizeof(xdag_hash_t), 1, f) != 1) {
			fclose(f);
			goto fail;
		}

		fclose(f);
	}

	if (!k->key) goto fail;
	
	k->prev = def_key;
	def_key = k;
	
	if (nkeys == maxnkeys) {
		struct xdag_public_key *newarr = (struct xdag_public_key *)
			realloc(keys_arr, ((maxnkeys | 0xff) + 1) * sizeof(struct xdag_public_key));
		if (!newarr) goto fail;
		
		maxnkeys |= 0xff;
		maxnkeys++;
		keys_arr = newarr;
	}

	keys_arr[nkeys].key = k->key;
	keys_arr[nkeys].pub = (uint64_t*)((uintptr_t)&k->pub | k->pub_bit);

	xdag_debug("Key %2d: priv=[%s] pub=[%02x:%s]", nkeys,
					xdag_log_hash(k->priv), 0x02 + k->pub_bit,  xdag_log_hash(k->pub));
	
	nkeys++;
	
	pthread_mutex_unlock(&wallet_mutex);
	
	return 0;
 
fail:
	pthread_mutex_unlock(&wallet_mutex);
	free(k);
	return -1;
}

/* generates a new key and sets is as defauld, returns its index */
int xdag_wallet_new_key(void)
{
	int res = add_key(0);

	if (!res)
		res = nkeys - 1;

	return res;
}

/* initializes a wallet */
int xdag_wallet_init(void)
{
	uint32_t priv32[sizeof(xdag_hash_t) / sizeof(uint32_t)];
	xdag_hash_t priv;
	FILE *f = xdag_open_file(WALLET_FILE, "rb");
	int n;

	if (!f) {
		if (add_key(0)) return -1;
		
//        f = fopen(WALLET_FILE, "r");
        f = xdag_open_file(WALLET_FILE, "r");
                if (!f) return -1;
		
		fread(priv32, sizeof(xdag_hash_t), 1, f);
		
		n = 1;
	} else {
		n = 0;
	}

	while (fread(priv32, sizeof(xdag_hash_t), 1, f) == 1) {
		xdag_user_crypt_action(priv32, n++, sizeof(xdag_hash_t) / sizeof(uint32_t), 2);
		memcpy(priv, priv32, sizeof(xdag_hash_t));
		add_key(priv);
	}

	fclose(f);
	
	return 0;
}

/* returns a default key, the index of the default key is written to *n_key */
struct xdag_public_key *xdag_wallet_default_key(int *n_key)
{
	if (nkeys) {
		if (n_key) {
			*n_key = nkeys - 1;
			return keys_arr + nkeys - 1;
		}
	}

	return 0;
}

/* returns an array of our keys */
struct xdag_public_key *xdag_wallet_our_keys(int *pnkeys)
{
	*pnkeys = nkeys;

	return keys_arr;
}

/* completes work with wallet */
void xdag_wallet_finish(void)
{
	pthread_mutex_lock(&wallet_mutex);
}

/* release wallet resource while program exit */
int xdag_wallet_uninit(void){
    if(keys_arr){
        free(keys_arr);
        keys_arr = 0;
    }
    nkeys = 0;
    maxnkeys = 0;
    return 0;
//TODO:make sure def_key need release
//    if(def_key){
//        free(def_key);
//        def_key = 0;
//    }
}

