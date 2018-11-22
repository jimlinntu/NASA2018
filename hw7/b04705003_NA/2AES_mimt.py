#!/usr/bin/env python3
from Crypto.Cipher import AES

class DoubleAES():
    def __init__(self, key0, key1):
        self.aes128_0 = AES.new(key=key0, mode=AES.MODE_ECB)
        self.aes128_1 = AES.new(key=key1, mode=AES.MODE_ECB)

    def encrypt(self, s):
        return self.aes128_1.encrypt(self.aes128_0.encrypt(s))

    def decrypt(self, data):
        return self.aes128_0.decrypt(self.aes128_1.decrypt(data))

def int2bytes(n):
    return bytes.fromhex('{0:032x}'.format(n))

def mimt(plaintext, cipher):
    cipher = bytes.fromhex(cipher)
    true_key = [None, None]
    # Save intermediate -> key0 
    mapping = {}
    for key0 in range(2**23):
        # change aes2 key
        aes2 = AES.new(key=int2bytes(key0), mode=AES.MODE_ECB)
        intermediate = aes2.encrypt(plaintext)
        mapping[intermediate] = key0
    
    # decode
    for key1 in range(2**23):
        aes2 = AES.new(key=int2bytes(key1), mode=AES.MODE_ECB)
        intermediate = aes2.decrypt(cipher)
        if intermediate in mapping:
            true_key[0] = mapping[intermediate]
            true_key[1] = key1 
            break
    #
    return tuple(true_key)

def main():
    #
    plaintext = "NoOneUses2AES_QQ"
    ciphertext = "f1a0cff39c4351102e5cad9d63acc3ef"
    key0, key1 = mimt(plaintext, ciphertext)
    print("Key0: {}, Key1: {}".format(key0, key1))



if __name__ == '__main__':
    main()