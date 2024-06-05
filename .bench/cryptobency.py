import os
import time
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
from cryptography.fernet import Fernet
from logfunc import logf

# File sizes in bytes
sizes = [1024, 1024**2, 1024 * 100, 1024**3]  # 1KB, 1MB, 100MB, 1GB

os.environ['LOGF_USE_PRINT'] = 'True'
os.environ['LOGF_SINGLE_MSG'] = 'True'
os.environ['LOGF_LOG_RETURN'] = 'False'

import logging


def get_random_bytes(size) -> bytes:
    return os.urandom(size)


def create_test_file(file_path, size):
    data = b'a' * size
    with open(file_path, 'wb') as f:
        f.write(data)


@logf()
def aes_encrypt(file_path, key, iv):
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


@logf()
def aes_decrypt(file_path, key):
    with open(file_path, 'rb') as f:
        iv = f.read(16)
        ciphertext = f.read()
    cipher = Cipher(
        algorithms.AES(key), modes.CBC(iv), backend=default_backend()
    )
    decryptor = cipher.decryptor()
    unpadder = padding.PKCS7(algorithms.AES.block_size).unpadder()
    padded_data = decryptor.update(ciphertext) + decryptor.finalize()
    data = unpadder.update(padded_data) + unpadder.finalize()
    with open(file_path + '.aes.dec', 'wb') as f:
        f.write(data)


@logf()
def chacha_encrypt(file_path, key, nonce):
    cipher = Cipher(
        algorithms.ChaCha20(key, nonce), mode=None, backend=default_backend()
    )
    encryptor = cipher.encryptor()
    with open(file_path, 'rb') as f:
        data = f.read()
    ciphertext = encryptor.update(data) + encryptor.finalize()
    with open(file_path + '.chacha', 'wb') as f:
        f.write(nonce + ciphertext)


@logf()
def chacha_decrypt(file_path, key):
    with open(file_path, 'rb') as f:
        nonce = f.read(16)
        ciphertext = f.read()
    cipher = Cipher(
        algorithms.ChaCha20(key, nonce), mode=None, backend=default_backend()
    )
    decryptor = cipher.decryptor()
    return decryptor.update(ciphertext) + decryptor.finalize()


@logf()
def aes_gcm_encrypt(file_path, key):
    iv = get_random_bytes(12)  # GCM typically uses a 12-byte IV
    cipher = Cipher(
        algorithms.AES(key), modes.GCM(iv), backend=default_backend()
    )
    encryptor = cipher.encryptor()
    with open(file_path, 'rb') as f:
        data = f.read()
    ciphertext = encryptor.update(data) + encryptor.finalize()
    with open(file_path + '.gcm', 'wb') as f:
        f.write(iv + encryptor.tag + ciphertext)
    print(
        f'AES-GCM IV: {iv.hex()} Tag: {encryptor.tag.hex()}'
    )  # For debugging


@logf()
def aes_gcm_decrypt(file_path, key):
    with open(file_path, 'rb') as f:
        iv = f.read(12)
        tag = f.read(16)
        ciphertext = f.read()
    print(f'AES-GCM IV: {iv.hex()} Tag: {tag.hex()}')  # For debugging
    cipher = Cipher(
        algorithms.AES(key), modes.GCM(iv, tag), backend=default_backend()
    )
    decryptor = cipher.decryptor()
    return decryptor.update(ciphertext) + decryptor.finalize()


@logf()
def fernet_encrypt(file_path, key):
    fernet = Fernet(key)
    with open(file_path, 'rb') as f:
        data = f.read()
    encrypted_data = fernet.encrypt(data)
    with open(file_path + '.fernet', 'wb') as f:
        f.write(encrypted_data)


@logf()
def fernet_decrypt(file_path, key):
    fernet = Fernet(key)
    with open(file_path, 'rb') as f:
        encrypted_data = f.read()
    return fernet.decrypt(encrypted_data)


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

    print('-----------------------------------')
