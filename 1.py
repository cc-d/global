import requests
import binascii
import sys
RPC_URL = "https://bitcoin-rpc.publicnode.com/"

def rpc_call(method, params):
    payload = {"jsonrpc": "1.0", "id": "py", "method": method, "params": params}
    resp = requests.post(RPC_URL, json=payload, timeout=15)
    resp.raise_for_status()
    return resp.json()["result"]

def decode_ascii(hexstr):
    try:
        raw = bytes.fromhex(hexstr)
        return raw.decode("ascii")
    except Exception:
        return None

def parse_block(block_identifier):
    blockhash = rpc_call("getblockhash", [block_identifier]) if isinstance(block_identifier, int) else block_identifier
    block = rpc_call("getblock", [blockhash, 2])
    print(f"Block {block['height']} ({blockhash}) has {len(block['tx'])} txs")

    # Decode coinbase of the first transaction (where the original message lives)
    coinbase_tx = block["tx"][0]
    if "vin" in coinbase_tx and "coinbase" in coinbase_tx["vin"][0]:
        ascii_str = decode_ascii(coinbase_tx["vin"][0]["coinbase"])
        if ascii_str:
            print(f"Coinbase ASCII: {ascii_str}")

    # OP_RETURN outputs and vin.scriptSig (optional)
    for tx in block["tx"]:
        for vout in tx.get("vout", []):
            hexdata = vout.get("scriptPubKey", {}).get("hex", "")
 #           print(hexdata)
            if hexdata.startswith("6a"):  # OP_RETURN prefix
                payload_hex = hexdata[2:]  # skip OP_RETURN
                ascii_str = decode_ascii(payload_hex)
                if ascii_str:
                    print(f"OP_RETURN ASCII: {ascii_str}")
        
        # Coinbase message
        coinbase_tx = block["tx"][0]
        if "vin" in coinbase_tx and "coinbase" in coinbase_tx["vin"][0]:
            ascii_str = decode_ascii(coinbase_tx["vin"][0]["coinbase"])
            if ascii_str:
                print(f"Coinbase ASCII: {ascii_str}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python parse_block.py <height_or_hash>")
        sys.exit(1)
    arg = sys.argv[1]
    block_id = int(arg) if arg.isdigit() else arg
    parse_block(block_id)
