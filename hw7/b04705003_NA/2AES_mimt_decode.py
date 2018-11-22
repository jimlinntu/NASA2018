#!/usr/bin/env python3
from mimt import DoubleAES, int2bytes
def main():
    key0, key1 = 6809501, 3927445
    flag_enc = bytes.fromhex("019847278c949131611d267c3bb1f833bdb8e692f12f237b90d900aeb17be714")
    aes2 = DoubleAES(key0=int2bytes(key0), key1=int2bytes(key1))
    flag = aes2.decrypt(flag_enc)
    print("{}".format(flag.decode("utf-8")))

if __name__ == '__main__':
    main()