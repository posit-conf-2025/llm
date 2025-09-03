#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# ///

#!/usr/bin/env python3
import argparse
import base64
import getpass
import hashlib
import os
import random
import sys
from pathlib import Path


def create_key(password: str, length: int) -> bytes:
    """Create a repeating key from password"""
    key_hash = hashlib.sha256(password.encode()).digest()
    key = (key_hash * ((length // len(key_hash)) + 1))[:length]
    return key


def xor_data(data: bytes, key: bytes) -> bytes:
    """XOR data with key"""
    return bytes(a ^ b for a, b in zip(data, key))


def encrypt_file(input_file, password):
    with open(input_file, "rb") as f:
        real_data = f.read()

    # Add substantial random padding
    prefix_size = random.randint(1024, 4096)  # 1-4KB random prefix
    suffix_size = random.randint(1024, 4096)  # 1-4KB random suffix

    random_prefix = os.urandom(prefix_size)
    random_suffix = os.urandom(suffix_size)

    # Store the real data boundaries (encrypted too)
    boundary_info = f"REAL:{prefix_size}:{len(real_data)}:REAL".encode()

    # Combine: boundary_info + random_prefix + real_data + random_suffix
    padded_data = boundary_info + random_prefix + real_data + random_suffix

    # Now encrypt everything
    key = create_key(password, len(padded_data))
    encrypted = xor_data(padded_data, key)
    encoded = base64.b64encode(encrypted)

    # Write to stdout
    sys.stdout.buffer.write(encoded)

    # Print status message to stderr so it doesn't interfere with output
    print("File encrypted successfully", file=sys.stderr)


def decrypt_file(input_file: Path, password: str):
    with open(input_file, "rb") as f:
        encoded_data = f.read()

    try:
        encrypted = base64.b64decode(encoded_data)
        key = create_key(password, len(encrypted))
        decrypted = xor_data(encrypted, key)

        # Find the boundary markers
        start_marker = b"REAL:"
        end_marker = b":REAL"

        start_pos = decrypted.find(start_marker)
        if start_pos == -1:
            raise ValueError("Invalid decryption - REAL: marker not found")

        end_pos = decrypted.find(end_marker, start_pos)
        if end_pos == -1:
            raise ValueError("Invalid decryption - :REAL marker not found")

        # Extract and parse boundary info: "REAL:1234:5678:REAL"
        boundary_section = decrypted[start_pos : end_pos + len(end_marker)]
        boundary_text = boundary_section.decode()

        # Parse: "REAL:prefix_size:real_data_size:REAL"
        parts = boundary_text.split(":")
        if len(parts) != 4 or parts[0] != "REAL" or parts[3] != "REAL":
            raise ValueError("Invalid boundary format")

        prefix_size = int(parts[1])
        real_data_size = int(parts[2])

        # Calculate positions
        boundary_info_size = len(boundary_section)
        real_data_start = start_pos + boundary_info_size + prefix_size
        real_data_end = real_data_start + real_data_size

        # Validate positions
        if real_data_end > len(decrypted):
            raise ValueError(
                "Invalid decryption - boundary information points beyond file"
            )

        # Extract real data
        real_data = decrypted[real_data_start:real_data_end]

        sys.stdout.buffer.write(real_data)

        print("File decrypted successfully!", file=sys.stderr)

    except Exception as e:
        print(f"Decryption failed: {e}", file=sys.stderr)
        print("Please check the password and try again.", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Simple file encryption/decryption tool"
    )
    parser.add_argument(
        "action", choices=["encrypt", "decrypt"], help="Action to perform"
    )
    parser.add_argument("input_file", help="Input file path")
    parser.add_argument(
        "-p", "--password", help="Password (will prompt if not provided)"
    )

    args = parser.parse_args()

    if args.password:
        password = args.password
    else:
        password = getpass.getpass("Enter password: ")

        if args.action == "encrypt":
            confirm_password = getpass.getpass("Confirm password: ")
            if password != confirm_password:
                print("Passwords do not match!", file=sys.stderr)
                sys.exit(1)

    input_path = Path(args.input_file)

    if not input_path.exists():
        print(f"Input file {input_path} does not exist", file=sys.stderr)
        sys.exit(1)

    if args.action == "encrypt":
        encrypt_file(input_path, password)
    else:
        decrypt_file(input_path, password)


if __name__ == "__main__":
    main()
