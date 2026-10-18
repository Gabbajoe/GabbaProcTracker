import hashlib
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from build_package import ROOT, RUNTIME, build, package_files, version
from upload_curseforge import metadata


class ReleaseTests(unittest.TestCase):
    def test_installable_reproducible_package(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            release, archive, checksum, count = build(ROOT, output, 'v' + version())
            first = archive.read_bytes()
            self.assertEqual(count, len(RUNTIME))
            with zipfile.ZipFile(archive) as package:
                self.assertEqual(set(package.namelist()), {'GabbaProcTracker/' + name for name in RUNTIME})
                self.assertIsNone(package.testzip())
            self.assertEqual(checksum.read_text().split()[0], hashlib.sha256(first).hexdigest())
            build(ROOT, output, 'v' + release)
            self.assertEqual(first, archive.read_bytes())

    def test_runtime_icon_format_and_transparent_corners(self):
        import struct
        for name, size in [('Icon.tga', 128), ('Minimap.tga', 64)]:
            data = (ROOT / 'Assets' / name).read_bytes()
            self.assertEqual(data[2], 2)  # uncompressed true-color TGA
            self.assertEqual(struct.unpack_from('<HH', data, 12), (size, size))
            self.assertEqual(data[16], 32)
            pixels = data[18 + data[0]:]
            if name == 'Minimap.tga':
                for index in [0, size - 1, size * (size - 1), size * size - 1]:
                    self.assertEqual(pixels[index * 4 + 3], 0)
                self.assertGreater(pixels[(size // 2 * size + size // 2) * 4 + 3], 240)

    def test_tag_mismatch_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                build(ROOT, Path(directory), 'v99.99.99')
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_manifest_missing_runtime_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in RUNTIME:
                (root / name).parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / name, root / name)
            with (root / 'GabbaProcTracker.toc').open('a') as toc:
                toc.write('\nNewRuntime.lua\n')
            with self.assertRaises(ValueError):
                package_files(root)

    def test_curseforge_release_types(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for suffix, expected in [('-dev.1', 'alpha'), ('-alpha.1', 'alpha'),
                                     ('-beta.1', 'beta'), ('-rc.1', 'beta'), ('', 'release')]:
                release = '1.0.0' + suffix
                (root / 'GabbaProcTracker.toc').write_text('## Interface: 11509\n## Version: ' + release + '\n')
                data = metadata(root, 'v' + release, 'notes', [{'name': '1.15.9', 'id': 123}])
                self.assertEqual(data['releaseType'], expected)
                self.assertEqual(data['gameVersions'], [123])

    def test_curseforge_ambiguous_or_missing_version_rejected(self):
        for versions in [[], [{'name': '1.15.8', 'id': 123}],
                         [{'name': '1.15.9', 'id': 123}, {'name': '1.15.9', 'id': 456}]]:
            with self.assertRaises(ValueError):
                metadata(ROOT, 'v' + version(), '', versions)


if __name__ == '__main__':
    unittest.main()
