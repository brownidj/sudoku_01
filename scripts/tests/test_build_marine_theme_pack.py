"""Regression checks for the distributable butterfly fish pack, not a mock UI."""
import contextlib
import hashlib
import importlib.util
import io
import json
import tempfile
import unittest
import zipfile
import wave
from pathlib import Path
from unittest.mock import patch

from PIL import Image

spec = importlib.util.spec_from_file_location(
    "marine_pack_builder", Path(__file__).resolve().parents[1] / "build_marine_theme_pack.py"
)
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
SPECIES = ["threadfin", "copperband", "raccoon", "saddled", "ornate",
           "meyers", "blackback", "redtail", "pyramid"]


class ButterflyFishPackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.project = Path(self.temp.name)
        self.source = self.project / "flutter_app/assets/images/marine"
        self.source.mkdir(parents=True)
        (self.project / "flutter_app/pubspec.yaml").write_text("version: 2.0.1+400\n")
        # Deliberately create these out of order; disk enumeration is not digit order.
        for digit in range(9, 0, -1):
            Image.new("RGB", (32, 32), (digit * 20, 100, 150)).save(
                self.source / f"{digit}_{SPECIES[digit - 1]}_butterflyfish.png"
            )
        Image.new("RGB", (32, 32), "red").save(self.source / "7_shark.png")
        Image.new("RGB", (32, 32), "red").save(self.source / "1_threadfin.png.png")
        audio = self.project / "flutter_app/assets/audio/marine"
        audio.mkdir(parents=True)
        for name in ["1_threadfin_1.mp3", "1_threadfin_2.mp3", "2_copperband_1.wav", "2_copperband_2.wav", "3_raccoon_1.wav", "3_raccoon_2.wav", "8_redtail_1.wav", "8_redtail_2.wav"]:
            if name.endswith(".wav"):
                with wave.open(str(audio / name), "wb") as wav:
                    wav.setnchannels(1)
                    wav.setsampwidth(2)
                    wav.setframerate(8000)
                    wav.writeframes(b"            (audio / name).write_bytes(name.encode())            (audio / name).write_bytes(name.encode())" * 800)
            else:
                (audio / name).write_bytes(name.encode())
        unused = self.project / "flutter_app/assets/audio/unused/marine"
        unused.mkdir(parents=True)
        (unused / "Cap'n Claw.mp3").write_bytes(b"wrong-animal")
        self.project_patch = patch.object(builder, "PROJECT", self.project)
        self.project_patch.start()
        self.addCleanup(self.project_patch.stop)

    def build(self, product_id="theme_marine"):
        output = self.project / "output"
        with contextlib.redirect_stdout(io.StringIO()):
            builder.build(output, False, product_id)
        return output

    def test_numeric_order_and_labels_come_from_the_selected_filenames(self):
        tiles = builder.discover_tiles(self.source)
        self.assertEqual([tile[0] for tile in tiles], [f"{name}_butterflyfish" for name in SPECIES])
        self.assertEqual([tile[1] for tile in tiles], [f"{name.title()} Butterfly Fish" for name in SPECIES])
        (self.source / "6_meyers_butterflyfish.png").rename(self.source / "6_meyers_longfin_butterflyfish.png")
        self.assertEqual(builder.discover_tiles(self.source)[5][1], "Meyers Longfin Butterfly Fish")

    def test_missing_and_duplicate_digits_are_rejected(self):
        missing = self.source / "9_pyramid_butterflyfish.png"
        missing.unlink()
        with self.assertRaisesRegex(ValueError, "each digit"):
            builder.discover_tiles(self.source)
        Image.new("RGB", (32, 32)).save(missing)
        Image.new("RGB", (32, 32)).save(self.source / "1_duplicate_butterflyfish.png")
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            builder.discover_tiles(self.source)

    def test_paid_zip_binds_every_digit_to_its_image_name_and_fish_audio(self):
        output = self.build()
        with zipfile.ZipFile(output / "marine_v4.zip") as archive:
            manifest = json.loads(archive.read("manifest.json"))
            self.assertEqual(manifest["theme_version"], 4)
            self.assertEqual(manifest["product_id"], "theme_marine")
            self.assertEqual([tile["accessibility_label"] for tile in manifest["tiles"]],
                             [f"{name.title()} Butterfly Fish" for name in SPECIES])
            for digit, tile in enumerate(manifest["tiles"], 1):
                self.assertEqual(tile["path"], f"tiles/tile_{digit:02d}.webp")
                with Image.open(io.BytesIO(archive.read(tile["path"]))) as image:
                    self.assertEqual(image.size, (512, 512))
                    self.assertLess(abs(image.getpixel((256, 256))[0] - digit * 20), 5)
            self.assertEqual([entry["digit"] for entry in manifest["audio"]["tiles"]], [1, 2, 3, 8])
            threadfin, copperband, raccoon, redtail = manifest["audio"]["tiles"]
            self.assertEqual(threadfin["long_press_variants"], ["audio/tunes/1_threadfin_1.mp3", "audio/tunes/1_threadfin_2.mp3"])
            self.assertEqual(copperband["long_press_variants"], ["audio/tunes/2_copperband_1.m4a", "audio/tunes/2_copperband_2.m4a"])
            self.assertEqual(redtail["long_press_variants"], ["audio/tunes/8_redtail_1.m4a", "audio/tunes/8_redtail_2.m4a"])
            self.assertEqual(raccoon["long_press_variants"], ["audio/tunes/3_raccoon_1.m4a", "audio/tunes/3_raccoon_2.m4a"])
            self.assertEqual(redtail["long_press"], redtail["long_press_variants"][0])
            self.assertEqual(manifest["audio"]["music"], threadfin["long_press_variants"] + copperband["long_press_variants"] + raccoon["long_press_variants"] + redtail["long_press_variants"])
            for name in manifest["audio"]["music"]:
                if name.endswith(".mp3"):
                    self.assertEqual(archive.read(name), Path(name).name.encode())
                else:
                    self.assertEqual(archive.read(name)[4:8], b"ftyp")
            self.assertFalse(any("Claw" in name for name in archive.namelist()))
            self.assertEqual(len([name for name in archive.namelist() if name.endswith((".mp3", ".m4a"))]), 8)
            for name, checksum in manifest["checksums"].items():
                self.assertEqual(hashlib.sha256(archive.read(name)).hexdigest(), checksum)
        catalogue = json.loads((output / "catalogue.json").read_text())["themes"][0]
        self.assertEqual(catalogue["version"], 4)
        self.assertEqual(catalogue["archive_path"], "ThemePacks/marine_v4.zip")
        self.assertFalse(catalogue["is_free"])
        self.assertEqual(catalogue["product_id"], "theme_marine")
        self.assertEqual(catalogue["sha256"], builder.digest(output / "marine_v4.zip"))
        apple = json.loads((output / "theme_catalogue_v4.apple.json").read_text())
        self.assertEqual(apple["fileSelectors"][1]["fileDestination"], "ThemePreviews/marine_v4.webp")
        report = json.loads((output / "marine_v4.build_report.json").read_text())
        self.assertEqual(report["tile_preview_mapping_count"], 4)
        self.assertEqual(report["creature_audio_count"], 8)
        self.assertEqual(report["background_music_count"], 8)
        self.assertEqual(set(report["source_sha256"]), {f"{i}_{name}_butterflyfish.png" for i, name in enumerate(SPECIES, 1)})

    def test_free_developer_archive_still_has_the_new_fish_and_version(self):
        output = self.build(None)
        entry = json.loads((output / "catalogue.json").read_text())["themes"][0]
        self.assertTrue(entry["is_free"])
        self.assertIsNone(entry["product_id"])
        self.assertEqual(entry["version"], 4)

    def test_audio_must_match_both_digit_and_species(self):
        source = self.project / "flutter_app/assets/audio/marine"
        (source / "8_redtail_1.wav").rename(source / "7_redtail_1.wav")
        with self.assertRaisesRegex(ValueError, "digit/species"):
            self.build()

    def test_missing_audio_does_not_use_archived_animals(self):
        for path in (self.project / "flutter_app/assets/audio/marine").iterdir():
            path.unlink()
        with self.assertRaisesRegex(ValueError, "No fish audio"):
            self.build()

    def test_unnumbered_wav_is_linked_to_its_species(self):
        source = self.project / "flutter_app/assets/audio/marine"
        (source / "1_threadfin_1.mp3").rename(source / "1_threadfin.wav")
        audio = builder.discover_audio(source, builder.discover_tiles(self.source))
        self.assertEqual(audio[1][0].name, "1_threadfin.wav")
