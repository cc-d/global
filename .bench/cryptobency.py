import os
import time
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
from cryptography.fernet import Fernet
from logfunc import logf

# File sizes in bytes
sizes = [1024, 1024 * 20, 1024**2, (1024**2) * 10, (1024**3) // 2]

os.environ['LOGF_USE_PRINT'] = 'True'
os.environ['LOGF_SINGLE_MSG'] = 'True'
os.environ['LOGF_LOG_RETURN'] = 'False'

import logging

results = {
    size: {
        'aes': {'encrypt': 0, 'decrypt': 0},
        'chacha': {'encrypt': 0, 'decrypt': 0},
        'aes_gcm': {'encrypt': 0, 'decrypt': 0},
        'fernet': {'encrypt': 0, 'decrypt': 0},
    }
    for size in sizes
}


def get_random_bytes(size) -> bytes:
    return os.urandom(size)


def create_test_file(file_path, size):
    data = b'a' * size
    with open(file_path, 'wb') as f:
        f.write(data)


@logf()
def aes_encrypt(file_path, key, iv):
    _start = time.time()
    cipher = Cipher(
        algorithms.AES(key), modes.CBC(iv), backend=default_backend()
    )
    encryptor = cipher.encryptor()
    padder = padding.PKCS7(algorithms.AES.block_size).padder()
    with open(file_path, 'rb') as f:
        data = f.read()
    padded_data = padder.update(data) + padder.finalize()
    ciphertext = encryptor.update(padded_data) + encryptor.finalize()
    with open(file_path + '.aes', 'wb') as f:
        f.write(iv + ciphertext)
    results[len(data)]['aes']['encrypt'] = time.time() - _start


@logf()
def aes_decrypt(file_path, key):
    _start = time.time()
    with open(file_path, 'rb') as f:
        iv = f.read(16)
        ciphertext = f.read()
    os.remove(file_path)
    cipher = Cipher(
        algorithms.AES(key), modes.CBC(iv), backend=default_backend()
    )
    decryptor = cipher.decryptor()
    unpadder = padding.PKCS7(algorithms.AES.block_size).unpadder()
    padded_data = decryptor.update(ciphertext) + decryptor.finalize()
    data = unpadder.update(padded_data) + unpadder.finalize()
    results[len(data)]['aes']['decrypt'] = time.time() - _start


@logf()
def chacha_encrypt(file_path, key, nonce):
    _start = time.time()
    cipher = Cipher(
        algorithms.ChaCha20(key, nonce), mode=None, backend=default_backend()
    )
    encryptor = cipher.encryptor()
    with open(file_path, 'rb') as f:
        data = f.read()
    ciphertext = encryptor.update(data) + encryptor.finalize()
    with open(file_path + '.chacha', 'wb') as f:
        f.write(nonce + ciphertext)
    results[len(data)]['chacha']['encrypt'] = time.time() - _start


@logf()
def chacha_decrypt(file_path, key):
    _start = time.time()
    with open(file_path, 'rb') as f:
        nonce = f.read(16)
        ciphertext = f.read()
    cipher = Cipher(
        algorithms.ChaCha20(key, nonce), mode=None, backend=default_backend()
    )
    decryptor = cipher.decryptor()
    data = decryptor.update(ciphertext) + decryptor.finalize()
    results[len(data)]['chacha']['decrypt'] = time.time() - _start


@logf()
def aes_gcm_encrypt(file_path, key):
    _start = time.time()
    iv = os.urandom(12)  # GCM typically uses a 12-byte IV
    cipher = Cipher(
        algorithms.AES(key), modes.GCM(iv), backend=default_backend()
    )
    encryptor = cipher.encryptor()
    with open(file_path, 'rb') as f:
        data = f.read()
    ciphertext = encryptor.update(data) + encryptor.finalize()
    with open(file_path + '.gcm', 'wb') as f:
        f.write(iv + encryptor.tag + ciphertext)
    results[len(data)]['aes_gcm']['encrypt'] = time.time() - _start


@logf()
def aes_gcm_decrypt(file_path, key):
    _start = time.time()
    with open(file_path, 'rb') as f:
        iv = f.read(12)
        tag = f.read(16)
        ciphertext = f.read()
    os.remove(file_path)
    cipher = Cipher(
        algorithms.AES(key), modes.GCM(iv, tag), backend=default_backend()
    )
    decryptor = cipher.decryptor()
    data = decryptor.update(ciphertext) + decryptor.finalize()
    results[len(data)]['aes_gcm']['decrypt'] = time.time() - _start


@logf()
def fernet_encrypt(file_path, key):
    _start = time.time()
    fernet = Fernet(key)
    with open(file_path, 'rb') as f:
        data = f.read()
    os.remove(file_path)
    encrypted_data = fernet.encrypt(data)
    with open(file_path + '.fernet', 'wb') as f:
        f.write(encrypted_data)
    results[len(data)]['fernet']['encrypt'] = time.time() - _start


@logf()
def fernet_decrypt(file_path, key):
    _start = time.time()
    fernet = Fernet(key)
    with open(file_path, 'rb') as f:
        encrypted_data = f.read()
    data = fernet.decrypt(encrypted_data)
    results[len(data)]['fernet']['decrypt'] = time.time() - _start


# Main benchmark loop
for size in sizes:
    file_path = f'/tmp/testfile_{size}'
    create_test_file(file_path, size)

    print(f'Benchmarking for file size: {size} bytes')

    key_aes = get_random_bytes(16)
    iv_aes = get_random_bytes(16)
    aes_encrypt(file_path, key_aes, iv_aes)
    aes_decrypt(file_path + '.aes', key_aes)

    key_chacha = get_random_bytes(32)
    nonce_chacha = get_random_bytes(16)
    chacha_encrypt(file_path, key_chacha, nonce_chacha)
    chacha_decrypt(file_path + '.chacha', key_chacha)

    key_aes_gcm = get_random_bytes(32)
    aes_gcm_encrypt(file_path, key_aes_gcm)
    aes_gcm_decrypt(file_path + '.gcm', key_aes_gcm)

    key_fernet = Fernet.generate_key()
    fernet_encrypt(file_path, key_fernet)
    fernet_decrypt(file_path + '.fernet', key_fernet)

# Print total results at the end
print('\nTotal Results:')
for size, algos in results.items():
    print(f'\nFile size: {size} bytes')
    for algo, times in algos.items():
    
        encrypt_time = times.get('encrypt', 'N/A')
        decrypt_time = times.get('decrypt', 'N/A')
        print(
            f'{algo.upper()} -> Encrypt: {encrypt_time:.4f}s, Decrypt: {decrypt_time:.4f}s'
        )
