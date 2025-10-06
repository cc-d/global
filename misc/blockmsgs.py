import requests
import string
import sys
import csv
import os
import argparse
import random
from time import sleep
from concurrent.futures import ThreadPoolExecutor, as_completed

RPC_URLS = [
    "https://bitcoin-rpc.publicnode.com/",
    "https://bitcoin-mainnet.public.blastapi.io",
]

CSV_FILENAME = "blockchain_messages.csv"


def rpc_call(method, params):
    """Make a resilient JSON-RPC call with node rotation."""
    urls = random.sample(RPC_URLS, len(RPC_URLS))
    payload = {
        "jsonrpc": "1.0",
        "id": "py",
        "method": method,
        "params": params,
    }
    for url in urls:
        try:
            resp = requests.post(url, json=payload, timeout=20)
            resp.raise_for_status()
            return resp.json()["result"]
        except (
            requests.exceptions.RequestException,
            KeyError,
            ValueError,
        ) as e:
            print(f"RPC call error at {url}: {e}", file=sys.stderr)
            continue

    print(
        f"Error: All RPC nodes failed for {method} with params {params}",
        file=sys.stderr,
    )
    return None


def decode_coinbase(hexstr):
    try:
        raw = bytes.fromhex(hexstr)
        return ''.join(
            c for c in raw.decode('latin1') if c in string.printable
        )
    except:
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
        return ''.join(
            c for c in payload.decode('latin1') if c in string.printable
        )
    except:
        return None


def parse_block(block_identifier, sleep_for=0.001):
    """Fetch and parse a single block for messages."""

    blockhash = (
        rpc_call("getblockhash", [block_identifier])
        if isinstance(block_identifier, int)
        else block_identifier
    )

    if not blockhash:
        return []

    sleep(sleep_for)

    block = rpc_call("getblock", [blockhash, 2])
    if not block:
        return []

    sleep(sleep_for)

    rows = []
    # Coinbase
    coinbase_tx = block["tx"][0]
    coinbase_hex = coinbase_tx["vin"][0].get("coinbase", "")
    msg = decode_coinbase(coinbase_hex)
    if msg:
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
        help="Single block height/hash or range (e.g., 800000-800010).",
    )
    parser.add_argument(
        "-t",
        "--threads",
        type=int,
        default=16,
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
        blocks_to_process = [
            (
                int(args.block_specifier)
                if args.block_specifier.isdigit()
                else args.block_specifier
            )
        ]

    file_exists = os.path.isfile(CSV_FILENAME)
    is_empty = os.path.getsize(CSV_FILENAME) == 0 if file_exists else True
    total_messages = 0

    try:
        with open(CSV_FILENAME, 'a', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
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
                    executor.submit(parse_block, blk): blk
                    for blk in blocks_to_process
                }
                for future in as_completed(futures):
                    try:
                        rows = future.result()
                        if rows:
                            writer.writerows(rows)
                            csvfile.flush()
                            total_messages += len(rows)
                    except Exception as e:
                        print(
                            f"Block {futures[future]} error: {e}",
                            file=sys.stderr,
                        )

            print(f"Processing complete. Found {total_messages} message(s).")
            print(f"Results saved to {CSV_FILENAME}")

    except KeyboardInterrupt:
        print("\nProcess interrupted by user. Exiting.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
