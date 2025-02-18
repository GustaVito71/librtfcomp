from pyrtfcomp import RTFCompress, RTFDecompress

# Example input data
test_data = b"This is a test string."

# Compress
compressed = RTFCompress(test_data)
print("Compressed:", compressed)

# Decompress
decompressed = RTFDecompress(compressed)
print("Decompressed:", decompressed)

# Validate round-trip
assert test_data == decompressed, "Round-trip failed!"

