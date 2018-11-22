#!/usr/bin/env python3
import sys
import hashlib
import AESCipher
import cryptolock
import re

def hash(two_chars):
    hashed = hashlib.sha256(two_chars).digest()
    return hashed 

def brute_force(ciphertext):
    # Backward decode
    possible_ciphertext_list = [[ciphertext], [], [], [], []]
    decoder_key_list = [[], [], [], []]
    # ? -> ENC -> 32 -> ENC -> 64 -> ENC -> 96 -> ENC -> 128
    # ciphertext -> DEC
    # First three step
    for pos in range(4):
        # For all possible ciphers in the previous step
        for now_cipher in possible_ciphertext_list[pos]:
            # brute_force all possible key and save all valid padded result and key
            for i in range(256):
                for j in range(256):
                    # Turn it into string
                    key = bytes([i, j])
                    # Digest
                    hashed = hash(key)
                    # Create cipher
                    aes_cipher = AESCipher.AESCipher(hashed)
                    # 
                    now_decoded = aes_cipher.decrypt(now_cipher)
                    
                    length = len(now_decoded)
                    # If pos <= 2, there should be 16 padding token in the back of now_decoded
                    if pos <= 2:
                        all_32 = True
                        for k in range(1, 16+1):
                            if ord(now_decoded[length-k:length-k+1]) != 16:
                                all_32 = False
                                break
                        if all_32:
                            # append unpadded decoded result
                            possible_ciphertext_list[pos+1].append(now_decoded[:-16])
                            decoder_key_list[pos].append(key)
                        else:
                            pass
                    # If pos == 3(last decoder)
                    else:
                        # pad number should be the same as last one
                        pad_number = ord(now_decoded[length-1:length])
                        # pad number should not bigger than 32 
                        if pad_number > 32:
                            continue
                        # if pad numbers are all valid
                        all_valid = True
                        for k in range(1, pad_number+1):
                            if ord(now_decoded[length-k:length-k+1]) != pad_number:
                                all_valid = False
                                break
                        if all_valid:
                            possible_ciphertext_list[pos+1].append(now_decoded[:-pad_number])
                            decoder_key_list[pos].append(key)
                        else:
                            pass
    # Try to decode every tokens
    pattern = re.compile("NASA")
    flag = None
    for i, cipher in enumerate(possible_ciphertext_list[-1]):
        try:
            if pattern.match(cipher.decode()) is not None:
                flag = cipher.decode()
                break
        except:
            pass

    return flag


def main():
    ciphertext = open("flag.encrypted", "rb").read()
    flag = brute_force(ciphertext)
    print(flag)

if __name__ == '__main__':
    main()