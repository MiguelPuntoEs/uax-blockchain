#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
csv2quiz_md.py
--------------
Convierte un CSV separado por punto y coma con preguntas tipo test
en Markdown compatible con Pandoc (listas anidadas).

Formato esperado:
Pregunta;Opción1;Opción2;Opción3;Opción4;Tiempo;RespuestaCorrecta(1-4)

Uso:
  python csv2quiz_md.py input.csv -o output.md
"""

import sys
import csv
import argparse
from typing import TextIO

LETTERS = {1: "a", 2: "b", 3: "c", 4: "d"}

def escape_md(text: str) -> str:
    if text is None:
        return ""
    return (text
            .replace("\\", "\\\\")
            .replace("*", r"\*")
            .replace("_", r"\_")
            .replace("`", r"\`"))

def row_to_markdown(idx: int, row: list[str]) -> str:
    """Convierte una fila en texto Markdown con lista numerada y sublista de opciones."""
    if len(row) < 7:
        raise ValueError(f"La fila {idx} no tiene 7 columnas: {row}")

    question = escape_md(row[0].strip())
    answers = [escape_md(x.strip()) for x in row[1:5]]
    correct_raw = row[6].strip()

    try:
        correct_idx = int(correct_raw)
        if correct_idx not in (1, 2, 3, 4):
            raise ValueError
    except Exception:
        raise ValueError(f"Índice de respuesta correcta inválido en fila {idx}: {correct_raw}")

    # Construcción de Markdown tipo lista anidada
    lines = [f"{idx}. {question}"]
    for i, ans in enumerate(answers, start=1):
        prefix = f"    {LETTERS[i]}. "
        if i == correct_idx:
            ans = f"**{ans}**"
        lines.append(f"{prefix}{ans}")
    lines.append("")  # línea en blanco entre preguntas
    return "\n".join(lines)

def convert(reader: csv.reader, out: TextIO) -> None:
    for idx, row in enumerate(reader, start=1):
        if not row or all(not (c.strip()) for c in row):
            continue
        md = row_to_markdown(idx, row)
        out.write(md)

def main():
    ap = argparse.ArgumentParser(description="Convierte CSV (;) de test a Markdown para Pandoc (listas anidadas).")
    ap.add_argument("input", nargs="?", help="Ruta del CSV de entrada; si se omite, lee de stdin.")
    ap.add_argument("-o", "--output", help="Ruta del Markdown de salida; si se omite, usa stdout.")
    ap.add_argument("--encoding", default="utf-8-sig", help="Codificación del CSV (por defecto utf-8-sig).")
    ap.add_argument("--delimiter", default=";", help="Delimitador del CSV (por defecto ';').")
    args = ap.parse_args()

    if args.input:
        infile = open(args.input, "r", encoding=args.encoding, newline="")
        close_in = True
    else:
        infile = sys.stdin
        close_in = False

    if args.output:
        outfile = open(args.output, "w", encoding="utf-8", newline="\n")
        close_out = True
    else:
        outfile = sys.stdout
        close_out = False

    try:
        reader = csv.reader(infile, delimiter=args.delimiter)
        convert(reader, outfile)
    finally:
        if close_in:
            infile.close()
        if close_out:
            outfile.close()

if __name__ == "__main__":
    main()