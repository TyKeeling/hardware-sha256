import numpy as np
np.set_printoptions(formatter={'int':bin})

ex = "hello world"

def pre_process(b: bytearray):
    lb = len(b)*8
    b.append(0b1000_0000)
    diff = (len(b) + 8) % 64
    if diff:
        b.extend(bytearray(64-diff))
    b.extend(lb.to_bytes(length=8, byteorder='big'))
    return b

k_l = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]

k = np.array(k_l, dtype=np.uint32)

hv_l = [
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
]

hv = np.array(hv_l, dtype=np.uint32)


def leftrotate(num, n):
    return np.uint32(num << n | num >> (32 - n))

def rightrotate(num, n):
    return np.uint32(num >> n | num << (32 - n))

def process_chunk(hv, k, preprocessed):
    w = np.zeros(64, dtype=np.uint32)

    for i in range(16):
        w[i] = int.from_bytes(preprocessed[4*i:4*i+4], "big")

    for i in range(16,64):
        s0 = rightrotate(w[i-15],7) ^ rightrotate(w[i-15],18) ^ w[i-15] >> 3
        s1 = rightrotate(w[i-2],17) ^ rightrotate(w[i-2],19) ^ w[i-2] >> 10
        w[i] = w[i-16] + s0 + w[i-7] + s1

    a = hv[0]
    b = hv[1]
    c = hv[2]
    d = hv[3]
    e = hv[4]
    f = hv[5]
    g = hv[6]
    h = hv[7]

    for i in range(64):
        s1 = rightrotate(e, 6) ^ rightrotate(e, 11) ^ rightrotate(e, 25)
        ch = (e & f) ^ (~e & g)
        temp1 = h + s1 + ch + k[i] + w[i]

        s0 = rightrotate(a, 2) ^ rightrotate(a, 13) ^ rightrotate(a, 22)
        maj = (a & b) ^ (a & c) ^ (b & c)
        temp2 = s0 + maj

        h = g
        g = f
        f = e
        e = d + temp1
        d = c
        c = b
        b = a
        a = temp1+temp2

    hv[0] = hv[0] + a
    hv[1] = hv[1] + b
    hv[2] = hv[2] + c
    hv[3] = hv[3] + d
    hv[4] = hv[4] + e
    hv[5] = hv[5] + f
    hv[6] = hv[6] + g
    hv[7] = hv[7] + h

    return hv


ob = pre_process(bytearray(ex, encoding="utf-8"))
print(''.join("{:02x}".format(x) for x in ob))
l = process_chunk(hv, k, ob)


np.set_printoptions(formatter={'int':hex})

print(l)