import tempfile
import unittest
from pathlib import Path

from link_contract import validate


class LinkContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "fish").mkdir()
        (self.root / "fish/config.fish").touch()
        self.links = {".config/fish": "fish"}

    def test_existing_source(self):
        self.assertEqual(validate(self.root, self.links, []), [])

    def test_missing_source(self):
        self.assertTrue(validate(self.root, {".config/missing": "missing"}, []))

    def test_generated_descendant_conflicts(self):
        self.assertTrue(validate(self.root, self.links, [".config/fish/config.fish"]))

    def test_generated_parent_conflicts(self):
        self.assertTrue(validate(self.root, self.links, [".config"]))

    def test_sibling_is_not_a_conflict(self):
        self.assertEqual(validate(self.root, self.links, [".config/fish-other"]), [])

    def test_source_cannot_escape_checkout(self):
        self.assertTrue(validate(self.root, {".config/fish": "../outside"}, []))

    def test_source_symlink_cannot_escape_checkout(self):
        (self.root / "escape").symlink_to("/etc")
        self.assertTrue(validate(self.root, {".config/escape": "escape"}, []))

    def test_overlapping_links_conflict(self):
        links = self.links | {".config/fish/config.fish": "fish/config.fish"}
        self.assertTrue(validate(self.root, links, []))


if __name__ == "__main__":
    unittest.main()
