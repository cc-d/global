import requests
import string
import sys
import csv
import os
import argparse
import random
import threading
import math
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor, as_completed

# A list of public RPC endpoints for load balancing and failover.
RPC_URLS = [
    "https://bitcoin-rpc.publicnode.com/",
    "https://bitcoin-mainnet.public.blastapi.io",
    
    ]
# The name of the output CSV file.
CSV_FILENAME = "blockchain_messages.csv"

# Use thread-local storage to ensure each thread has its own session and URL rotation.
thread_local_data = threading.local()

def get_session():
    """Initializes or retrieves a thread-local requests session."""
    if not hasattr(thread_local_data, 'session'):
        thread_local_data.session = requests.Session()
    return thread_local_data.session

def rpc_call(method, params):
    """
    Makes a resilient JSON-RPC call, rotating through available public nodes on failure.
    """
    if not hasattr(thread_local_data, 'rpc_urls'):
        # Shuffle RPC_URLS for each thread to distribute initial load randomly.
        thread_local_data.rpc_urls = random.sample(RPC_URLS, len(RPC_URLS))

    session = get_session()
    # Attempt the call on each URL in this thread's list until one succeeds.
    for i, url in enumerate(thread_local_data.rpc_urls):
        try:
            payload = {"jsonrpc": "1.0", "id": "py", "method": method, "params": params}
            resp = session.post(url, json=payload, timeout=20)
            resp.raise_for_status()
            # On success, rotate the list so the next call uses the next URL.
            thread_local_data.rpc_urls = thread_local_data.rpc_urls[i+1:] + thread_local_data.rpc_urls[:i+1]
            return resp.json()["result"]
        except (requests.exceptions.RequestException, KeyError, ValueError):
            # If a node fails, we just continue to the next one in the list.
            continue
    # If all nodes fail for this request, print an error and return None.
    print(f"Error: All RPC nodes failed for RPC call {method} with params {params}", file=sys.stderr)
    return None


def decode_coinbase(hexstr):
    """Decodes coinbase data, filtering for printable characters."""
    try:
        raw = bytes.fromhex(hexstr)
        return ''.join(c for c in raw.decode('latin1') if c in string.printable)
    except (ValueError, TypeError):
        return None

def decode_op_return(hexstr):
    """Decodes OP_RETURN data, correctly handling Bitcoin's script pushdata opcodes."""
    if not hexstr.startswith("6a"):
        return None
    try:
        raw = bytes.fromhex(hexstr)
        if len(raw) < 2: return None
        opcode, offset, payload = raw[1], 2, b''
        if 0x01 <= opcode <= 0x4b:
            length = opcode
            if len(raw) < offset + length: return None
            payload = raw[offset:offset+length]
        elif opcode == 0x4c: # OP_PUSHDATA1
            if len(raw) < offset + 1: return None
            length = raw[offset]
            offset += 1
            if len(raw) < offset + length: return None
            payload = raw[offset:offset+length]
        elif opcode == 0x4d: # OP_PUSHDATA2
            if len(raw) < offset + 2: return None
            length = int.from_bytes(raw[offset:offset+2], 'little')
            offset += 2
            if len(raw) < offset + length: return None
            payload = raw[offset:offset+length]
        else: return None
        return ''.join(c for c in payload.decode('latin1') if c in string.printable)
    except Exception:
        return None

def parse_block(block_identifier):
    """
    Fetches and parses a single block, returning any found messages as CSV rows.
    """
    blockhash = rpc_call("getblockhash", [block_identifier]) if isinstance(block_identifier, int) else block_identifier
    if not blockhash: return [], None

    block = rpc_call("getblock", [blockhash, 2])
    if not block: return [], None

    rows_to_write, print_buffer = [], []
    # 1. Coinbase message
    coinbase_tx = block["tx"][0]
    coinbase_hex = coinbase_tx["vin"][0].get("coinbase", "")
    msg = decode_coinbase(coinbase_hex)
    if msg:
        print_buffer.append(f"  Found Coinbase message: {msg}")
        rows_to_write.append([block['height'], blockhash, coinbase_tx['txid'], 'coinbase', msg])

    # 2. OP_RETURN outputs
    for tx in block["tx"]:
        for vout in tx.get("vout", []):
            hexdata = vout.get("scriptPubKey", {}).get("hex", "")
            op_msg = decode_op_return(hexdata)
            if op_msg:
                print_buffer.append(f"  Found OP_RETURN message in tx {tx['txid']}: {op_msg}")
                rows_to_write.append([block['height'], blockhash, tx['txid'], 'op_return', op_msg])
    
    # Prepare console output only if a message was found
    final_print_output = None
    if print_buffer:
        header = f"\n--- Found messages in Block {block['height']} ({blockhash}) ---"
        footer = f"--- Finished block {block['height']} ---"
        final_print_output = "\n".join([header] + print_buffer + [footer])

    return rows_to_write, final_print_output

def process_chunk(block_chunk, num_threads):
    """
    Worker function executed by each process. It uses a ThreadPool to process a chunk of blocks.
    """
    all_rows = []
    all_prints = []
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        future_to_block = {executor.submit(parse_block, block): block for block in block_chunk}
        for future in as_completed(future_to_block):
            try:
                rows, print_output = future.result()
                if rows: all_rows.extend(rows)
                if print_output: all_prints.append(print_output)
            except Exception as exc:
                block_id = future_to_block[future]
                print(f"Block {block_id} generated an exception: {exc}", file=sys.stderr)
    return all_rows, all_prints

def main():
    parser = argparse.ArgumentParser(
        description="Parse Bitcoin blocks for messages using multiple processes and RPC nodes.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument("block_specifier", help="A single block height/hash or a range (e.g., 800000-800010).")
    parser.add_argument("-c", "--cores", type=int, default=os.cpu_count(), help="Number of CPU cores (processes) to use. Defaults to system's max.")
    parser.add_argument("-t", "--threads-per-core", type=int, default=16, help="Number of concurrent network threads per core. Defaults to 16.")
    args = parser.parse_args()

    blocks_to_process = []
    if '-' in args.block_specifier:
        try:
            start, end = map(int, args.block_specifier.split('-'))
            if start > end: raise ValueError("Start of range cannot be greater than the end.")
            blocks_to_process = list(range(start, end + 1))
        except ValueError as e:
            print(f"Error: Invalid range format. {e}", file=sys.stderr); sys.exit(1)
    else:
        block_id = int(args.block_specifier) if args.block_specifier.isdigit() else args.block_specifier
        blocks_to_process.append(block_id)

    file_exists = os.path.isfile(CSV_FILENAME)
    is_empty = os.path.getsize(CSV_FILENAME) == 0 if file_exists else True
    total_messages_found, total_blocks_processed = 0, 0

    try:
        with open(CSV_FILENAME, 'a', newline='', encoding='utf-8') as csvfile:
            csv_writer = csv.writer(csvfile)
            if not file_exists or is_empty:
                csv_writer.writerow(["block_height", "block_hash", "txid", "message_type", "message"])

            num_processes = min(args.cores, len(blocks_to_process))
            chunk_size = math.ceil(len(blocks_to_process) / num_processes) if num_processes > 0 else 0
            chunks = [blocks_to_process[i:i + chunk_size] for i in range(0, len(blocks_to_process), chunk_size)] if chunk_size > 0 else []

            print(f"Processing {len(blocks_to_process)} block(s) using {num_processes} processes and up to {args.threads_per_core} threads each...")
            
            with ProcessPoolExecutor(max_workers=num_processes) as executor:
                future_to_chunk = {executor.submit(process_chunk, chunk, args.threads_per_core): chunk for chunk in chunks}
                for future in as_completed(future_to_chunk):
                    chunk_rows, chunk_prints = future.result()
                    if chunk_prints:
                        for p_out in chunk_prints: print(p_out)
                    if chunk_rows:
                        csv_writer.writerows(chunk_rows)
                        csvfile.flush() # Ensure data is written immediately
                        total_messages_found += len(chunk_rows)
                    
                    original_chunk = future_to_chunk[future]
                    total_blocks_processed += len(original_chunk)
                    progress = (total_blocks_processed / len(blocks_to_process)) * 100
                    sys.stdout.write(f"\rProgress: {total_blocks_processed}/{len(blocks_to_process)} blocks processed ({progress:.2f}%)")
                    sys.stdout.flush()

            print(f"\n\nProcessing complete. Found {total_messages_found} total message(s).")
            print(f"Results have been saved to {CSV_FILENAME}")

    except IOError as e:
        print(f"\nError writing to file {CSV_FILENAME}: {e}", file=sys.stderr); sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nProcess interrupted by user. Exiting.", file=sys.stderr); sys.exit(1)

if __name__ == "__main__":
    main()


