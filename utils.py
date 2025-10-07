import hashlib

def sha256d(b: bytes) -> bytes:
    return hashlib.sha256(hashlib.sha256(b).digest()).digest()

def u32_le(n: int) -> bytes:
    """Entero de 32 bits a little-endian (4 bytes)."""
    return n.to_bytes(4, byteorder="little", signed=False)

def hex_le(s: str) -> bytes:
    """
    Toma un hex mostrado en "formato humano" (big-endian),
    y lo convierte a bytes little-endian como exige el header.
    """
    b = bytes.fromhex(s)
    return b[::-1]  # invertir a little-endian

# -------------------------
# Conversión nBits (compact) -> target entero
# -------------------------
def bits_to_target(bits: int) -> int:
    """
    nBits es un formato compacto: 1 byte de exponente y 3 de mantisa.
    target = mantissa * 256^(exponent-3)
    """
    exponent = bits >> 24
    mantissa = bits & 0xFFFFFF
    return mantissa * (1 << (8 * (exponent - 3)))

def hash_to_int_be(h: bytes) -> int:
    """Interpreta el hash (bytes) como entero big-endian."""
    return int.from_bytes(h, byteorder="big")