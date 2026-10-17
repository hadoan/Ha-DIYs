#!/usr/bin/env python3
"""Check a binary STL for closed, consistently oriented, nondegenerate geometry."""

from collections import Counter, defaultdict
from math import isfinite
from pathlib import Path
from struct import unpack_from
import sys


def check(path: Path, expected_shells: int = 1) -> None:
    data = path.read_bytes()
    if len(data) < 84:
        raise ValueError("STL is too short")
    count = unpack_from("<I", data, 80)[0]
    if count == 0 or len(data) != 84 + 50 * count:
        raise ValueError("Expected a nonempty binary STL with exact triangle count")

    edges = Counter()
    directed_edges = Counter()
    bounds_min = [float("inf")] * 3
    bounds_max = [float("-inf")] * 3
    signed_volume_six = 0.0
    for index in range(count):
        values = unpack_from("<12f", data, 84 + 50 * index)
        vertices = [tuple(values[i : i + 3]) for i in (3, 6, 9)]
        if not all(isfinite(v) for xyz in vertices for v in xyz):
            raise ValueError(f"Triangle {index} has a nonfinite coordinate")
        if len(set(vertices)) != 3:
            raise ValueError(f"Triangle {index} is degenerate")
        a, b, c = vertices
        ab = [b[i] - a[i] for i in range(3)]
        ac = [c[i] - a[i] for i in range(3)]
        cross = (
            ab[1] * ac[2] - ab[2] * ac[1],
            ab[2] * ac[0] - ab[0] * ac[2],
            ab[0] * ac[1] - ab[1] * ac[0],
        )
        if sum(v * v for v in cross) < 1e-12:
            raise ValueError(f"Triangle {index} has near-zero area")
        signed_volume_six += sum(a[i] * cross[i] for i in range(3))
        for xyz in vertices:
            for i, value in enumerate(xyz):
                bounds_min[i] = min(bounds_min[i], value)
                bounds_max[i] = max(bounds_max[i], value)
        for u, v in ((a, b), (b, c), (c, a)):
            edges[tuple(sorted((u, v)))] += 1
            directed_edges[(u, v)] += 1

    bad_edges = sum(1 for usage in edges.values() if usage != 2)
    bad_orientation = sum(
        1 for (u, v) in edges if directed_edges[(u, v)] != 1 or directed_edges[(v, u)] != 1
    )
    neighbors = defaultdict(set)
    for u, v in edges:
        neighbors[u].add(v)
        neighbors[v].add(u)
    unvisited = set(neighbors)
    shell_count = 0
    shell_floor_heights = []
    while unvisited:
        shell_count += 1
        first = unvisited.pop()
        pending = [first]
        shell_floor = first[2]
        while pending:
            current = pending.pop()
            shell_floor = min(shell_floor, current[2])
            for neighbor in neighbors[current]:
                if neighbor in unvisited:
                    unvisited.remove(neighbor)
                    pending.append(neighbor)
        shell_floor_heights.append(shell_floor)
    if bad_edges or bad_orientation or shell_count != expected_shells or signed_volume_six <= 0:
        raise ValueError(
            f"Invalid shell: {bad_edges} non-manifold edges, "
            f"{bad_orientation} inconsistent edges, shells={shell_count} "
            f"(expected {expected_shells}), "
            f"signed volume {signed_volume_six / 6:.3f} mm^3"
        )
    if expected_shells > 1 and any(abs(z) > 0.001 for z in shell_floor_heights):
        raise ValueError("At least one batch shell does not touch the Z=0 bed plane")
    size = [bounds_max[i] - bounds_min[i] for i in range(3)]
    print(
        f"PASS {path}: {count} triangles, {shell_count} watertight oriented "
        f"{'shell' if shell_count == 1 else 'shells'}, "
        f"size {size[0]:.2f} x {size[1]:.2f} x {size[2]:.2f} mm, "
        f"volume {signed_volume_six / 6:.2f} mm^3"
    )


if __name__ == "__main__":
    if len(sys.argv) not in (2, 4) or (
        len(sys.argv) == 4 and sys.argv[2] != "--shells"
    ):
        raise SystemExit("Usage: python3 check_stl.py FILE.stl [--shells COUNT]")
    try:
        check(Path(sys.argv[1]), int(sys.argv[3]) if len(sys.argv) == 4 else 1)
    except ValueError as error:
        raise SystemExit(f"FAIL {sys.argv[1]}: {error}") from error
