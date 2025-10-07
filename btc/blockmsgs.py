import requests
import string
import sys
import csv
import os
import argparse
import random
from time import sleep
from concurrent.futures import ThreadPoolExecutor, as_completed

os.chdir(os.path.dirname(os.path.abspath(__file__)))


with open('blockhashes.txt', 'r') as f:
    BLOCK_HASHES = {int(k): v for k, v in (line.strip().split() for line in f)}

RPC_URLS = [
    "https://bitcoin-rpc.publicnode.com/",
    "https://bitcoin-mainnet.public.blastapi.io",
    "https://bitcoin.therpc.io",
]

CSV_FILENAME = "blockchain_messages.csv"


class RpcError(Exception):
    pass


def rpc_call(method, params, retries=3):
    """Make a resilient JSON-RPC call with node rotation and retries."""
    urls = random.sample(RPC_URLS, len(RPC_URLS))
    payload = {
        "jsonrpc": "1.0",
        "id": "py",
        "method": method,
        "params": params,
    }
    errs = set()
    for attempt in range(retries):

        url = urls[attempt % len(urls)]
        print(f"Attempt {attempt+1}/{retries} - {url} {payload}")
        try:
            resp = requests.post(url, json=payload, timeout=20)
            resp.raise_for_status()
            resp = resp.json()
            if resp.get("error") is None:
                return resp["result"]
            raise ValueError(f'Error in return JSON: {resp["error"]}')
        except Exception as e:
            print(f"RPC call error at {url}: {e}", file=sys.stderr)
            errs.add(f'{e}')
        sleep(retries * 0.1)
    raise RpcError(
        f'All RPC nodes failed for {method} after {retries} retries {errs}'
    )


def decode_coinbase(hexstr):
    try:
        raw = bytes.fromhex(hexstr)
        text = raw.decode('utf-8', errors='replace')
        return text
    except Exception:
        return None


def decode_op_return(hexstr):
    if not hexstr.startswith("6a"):
        return None
    try:
        raw = bytes.fromhex(hexstr)
        if len(raw) < 2:
            return None
        opcode, offset, payload = raw[1], 2, b''
        if 0x01 <= opcode <= 0x4B:
            length = opcode
            if len(raw) < offset + length:
                return None
            payload = raw[offset : offset + length]
        elif opcode == 0x4C:
            length = raw[offset]
            offset += 1
            if len(raw) < offset + length:
                return None
            payload = raw[offset : offset + length]
        elif opcode == 0x4D:
            length = int.from_bytes(raw[offset : offset + 2], 'little')
            offset += 2
            if len(raw) < offset + length:
                return None
            payload = raw[offset : offset + length]
        else:
            return None
        text = payload.decode('utf-8', errors='replace')
        return text

    except:
        return None


def parse_block(blockid, blockhash, sleep_for=0.001):
    """Fetch and parse a single block for messages."""
    print(blockhash, blockid)
    sleep(sleep_for)

    try:
        block = rpc_call("getblock", [blockhash, 2])
    except Exception as e:
        with open('errors.log', 'a') as ef:
            ef.write(f"{blockid} {blockhash} {e}\n")

        return []

    rows = []
    # Coinbase
    coinbase_tx = block["tx"][0]
    coinbase_hex = coinbase_tx["vin"][0].get("coinbase", "")
    msg = decode_coinbase(coinbase_hex)
    rows.append(
        [block['height'], blockhash, coinbase_tx['txid'], 'coinbase', msg]
    )

    # OP_RETURN outputs
    for tx in block["tx"]:
        for vout in tx.get("vout", []):
            hexdata = vout.get("scriptPubKey", {}).get("hex", "")
            op_msg = decode_op_return(hexdata)
            if op_msg:
                rows.append(
                    [
                        block['height'],
                        blockhash,
                        tx['txid'],
                        'op_return',
                        op_msg,
                    ]
                )

    return rows


def main():
    parser = argparse.ArgumentParser(
        description="Parse Bitcoin blocks for messages."
    )
    parser.add_argument(
        "block_specifier",
        nargs="?",
        help="Single block height/hash or range (e.g., 800000-800010).",
    )
    parser.add_argument(
        "-t",
        "--threads",
        type=int,
        default=4,
        help="Number of concurrent threads.",
    )
    args = parser.parse_args()

    # Build block list
    if '-' in args.block_specifier:
        start, end = map(int, args.block_specifier.split('-'))
        if start < end:
            blocks_to_process = list(range(start, end + 1))
        else:
            blocks_to_process = list(range(start, end + 1, -1))
    else:
        args.block_specifier = (
            int(args.block_specifier)
            if args.block_specifier.isdigit()
            else args.block_specifier
        )
        blocks_to_process = [args.block_specifier]

    blocks_to_process = [
        ((b, BLOCK_HASHES[b]) if isinstance(b, int) else (b, None))
        for b in blocks_to_process
    ]

    file_exists = os.path.isfile(CSV_FILENAME)
    is_empty = os.path.getsize(CSV_FILENAME) == 0 if file_exists else True
    total_messages = 0

    try:
        with open(CSV_FILENAME, 'a', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(
                csvfile, escapechar='\\', quoting=csv.QUOTE_NONE
            )
            if not file_exists or is_empty:
                writer.writerow(
                    [
                        "block_height",
                        "block_hash",
                        "txid",
                        "message_type",
                        "message",
                    ]
                )

            with ThreadPoolExecutor(max_workers=args.threads) as executor:
                futures = {
                    executor.submit(parse_block, blk[0], blk[1]): blk
                    for blk in blocks_to_process
                }
                for future in as_completed(futures):
                    rows = future.result()

                    if rows:
                        writer.writerows(rows)
                        csvfile.flush()
                        total_messages += len(rows)
            print(f"Processing complete. Found {total_messages} message(s).")
            print(f"Results saved to {CSV_FILENAME}")

    except KeyboardInterrupt:
        print("\nProcess interrupted by user. Exiting.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
