import concurrent.futures
import glob
import os

from hardware_app_tester.evidence import generate_report_basename, write_evidence


def test_write_evidence_creates_json_and_md(tmp_path):
    json_path, md_path = write_evidence(
        str(tmp_path), "unit_test", {"hello": "world"}, "# Hello\n"
    )
    assert json_path.exists()
    assert md_path.exists()
    assert json_path.suffix == ".json"
    assert md_path.suffix == ".md"
    assert json_path.stem == md_path.stem


def test_basenames_are_unique_across_rapid_calls():
    names = {generate_report_basename("x") for _ in range(50)}
    assert len(names) == 50


def test_concurrent_writes_produce_no_collisions(tmp_path):
    def _write(i):
        return write_evidence(str(tmp_path), "concurrent", {"i": i}, f"# run {i}\n")

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as pool:
        results = list(pool.map(_write, range(10)))

    json_paths = [str(r[0]) for r in results]
    assert len(json_paths) == len(set(json_paths)), "evidence filenames collided"

    on_disk = glob.glob(os.path.join(str(tmp_path), "concurrent_*.json"))
    assert len(on_disk) == 10
