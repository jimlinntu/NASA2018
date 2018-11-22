#!/usr/bin/env python3
import socket
from pwn import *
import pickle
import random
import codecs

class Agent():
    def __init__(self):
        self.remote_host = "linux13.csie.org"
        self.tcp_port = 7122
        self.r = remote(self.remote_host, self.tcp_port)

    def receive(self):  
        round_string = self.r.recvline()
        B = int(self.r.recvline().decode().split(" ")[2].strip("\n"))
        generate_message = self.r.recvuntil("Generate 'a' and send A = g^a mod p to the server: ")
        return B

    def send(self, A):
        self.r.sendline(str(A))
        return 

    def receive_flag(self):
        flag_message = self.r.recvline()
        FLAG = flag_message.decode().strip("\n").split(" ")[2]
        return int(FLAG)

    def close(self):
        self.r.close()

def main(verbose=False):
    if verbose == False:
        context.log_level = "error"
    p = 262603487816194488181258352326988232210376591996146252542919605878805005469693782312718749915099841408908446760404481236646436295067318626356598442952156854984209550714670817589388406059285064542905718710475775121565983586780136825600264380868770029680925618588391997934473191054590812256197806034618157751903
    a = 10243 # Fixed a
    g = [None] * 10
    possible_password = [int(hashlib.sha512(str(i).encode()).hexdigest(), 16) for i in range(1, 20+1)]
    # Guess g1, g2 ..... g10
    for i in range(10):
        # Guess g_i
        for pwd_i in possible_password:
            #
            # Create two agent
            c1 = Agent()
            c2 = Agent()
            g_i = pow(pwd_i, 2, p)
            A = pow(g_i, a, p)
            if not 514 <= A < p-514:
                c1.close()
                c2.close()
                continue
            #
            B_c_1i = None
            B_c_2i = None
            for round_num in range(10):
                # Get response
                B_c_1 = c1.receive()
                B_c_2 = c2.receive()
                
                if round_num == i:
                    B_c_1i = B_c_1
                    B_c_2i = B_c_2
                    c1.send(A)
                    c2.send(A)
                else:
                    c1.send(B_c_2)
                    c2.send(B_c_1)
            
            FLAG_c_1 = c1.receive_flag()
            FLAG_c_2 = c2.receive_flag()
            # Check if FLAG_c_1 xor (g_i)^(ab_c1) == FLAG_c_2 xor (g_i)^(ab_c2) is equal
            decoder_c1 = int(hashlib.sha512(str(pow(B_c_1i, a, p)).encode()).hexdigest(), 16)
            decoder_c2 = int(hashlib.sha512(str(pow(B_c_2i, a, p)).encode()).hexdigest(), 16)
            # Test if equal
            if FLAG_c_1 ^ decoder_c1 == FLAG_c_2 ^ decoder_c2:
                g[i] = g_i
                #print("Round {}\'s key found. {}".format(i+1, g_i))
                break
            # Close connection
            c1.close()
            c2.close()

    pickle.dump(g, open("g_password", "wb"))
    
    print(g)
    # Get flag
    key = 0
    c = Agent()
    for i, g_i in enumerate(g):
        B = c.receive()
        while True:
            a = random.randint(2, p)
            A = pow(g_i, a, p)
            if 514 <= A < p-514:
               break 
        c.send(A)
        K = pow(B, a, p)
        key ^= int(hashlib.sha512(str(K).encode()).hexdigest(), 16)

    FLAG = c.receive_flag()
    c.close()
    FLAG = codecs.decode(format(FLAG ^ key, 'x'), encoding="hex")
    print(FLAG.decode()) 

        
if __name__ == '__main__':
    main()