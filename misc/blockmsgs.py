import requests
import string
import sys

RPC_URL = "https://bitcoin-rpc.publicnode.com/"

def rpc_call(method, params):
    payload = {"jsonrpc": "1.0", "id": "py", "method": method, "params": params}
    resp = requests.post(RPC_URL, json=payload, timeout=15)
    resp.raise_for_status()
    return resp.json()["result"]

def decode_coinbase(hexstr):
    try:
        raw = bytes.fromhex(hexstr)
        return ''.join(c for c in raw.decode('latin1') if c in string.printable)
    except Exception:
        return None

def decode_op_return(hexstr):
    try:
        if hexstr.startswith("6a"):  # OP_RETURN prefix
            payload_hex = hexstr[2:]
            raw = bytes.fromhex(payload_hex)
            return ''.join(c for c in raw.decode('latin1') if c in string.printable)
    except Exception:
        return None

def parse_block(block_identifier):
    blockhash = rpc_call("getblockhash", [block_identifier]) if isinstance(block_identifier, int) else block_identifier
    block = rpc_call("getblock", [blockhash, 2])
    print(f"Block {block['height']} ({blockhash})")

    # Coinbase message
    coinbase_tx = block["tx"][0]
    coinbase_hex = coinbase_tx["vin"][0].get("coinbase", "")
    msg = decode_coinbase(coinbase_hex)
    if msg:
        print(f"Coinbase message: {msg}")

    # OP_RETURN outputs
    for tx in block["tx"]:
        for vout in tx.get("vout", []):
            hexdata = vout.get("scriptPubKey", {}).get("hex", "")
            msg = decode_op_return(hexdata)
            if msg:
                print(f"OP_RETURN message: {msg}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python parse_block.py <height_or_hash>")
        sys.exit(1)
    arg = sys.argv[1]
    block_id = int(arg) if arg.isdigit() else arg
    parse_block(block_id)

