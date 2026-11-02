"""Exercise desktop directory links with real Stow and atomic application saves."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]


class DesktopDeployment(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.repo = self.root / 'dotfiles'
        shutil.copytree(SOURCE, self.repo, ignore=shutil.ignore_patterns('.git', '__pycache__'))
        self.home = self.root / 'home'
        self.home.mkdir()
        self.agents = self.root / 'agents'
        self.agents.mkdir()
        (self.agents / 'Makefile').write_text('check uninstall:\n\t@true\n')
        self.git('init', '-q')
        self.git('add', '.')

    def git(self, *args):
        return subprocess.check_output(['git', '-C', str(self.repo), *args], text=True)

    def make(self, target):
        subprocess.run(['make', '-s', target, f'TARGET={self.home}',
                        f'AGENT_CONFIG_DIR={self.agents}'], cwd=self.repo,
                       check=True, stdout=subprocess.DEVNULL)

    def test_directory_handoff_backs_up_old_config_and_preserves_generated_files(self):
        niri = self.home / '.config/niri'
        (niri / 'dms').mkdir(parents=True)
        (niri / 'config.kdl').write_text('old preferences\n')
        (niri / 'dms/colors.kdl').write_text('generated colors\n')
        (niri / 'dms/outputs.kdl').write_text('machine outputs\n')
        settings = self.home / '.config/dms/settings.json'
        settings.parent.mkdir()
        settings.write_text('{"untouched": true}')
        fragments = settings.parent / 'config.d'
        fragments.mkdir()
        (fragments / 'personal.json').write_text('{"clockFormat":"24h"}')
        self.make('stow')
        self.assertTrue(niri.is_symlink())
        self.assertTrue((self.home / '.config/dms/config.d').is_symlink())
        backups = list((self.home / '.dotfiles-backups').glob('*/.config/niri/config.kdl'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'old preferences\n')
        saved_fragments = list((self.home / '.dotfiles-backups').glob('*/.config/dms/config.d/personal.json'))
        self.assertEqual(len(saved_fragments), 1)
        self.assertEqual(json.loads(saved_fragments[0].read_text()), {'clockFormat': '24h'})
        self.assertFalse((fragments / 'personal.json').exists())
        self.assertEqual((niri / 'dms/colors.kdl').read_text(), 'generated colors\n')
        self.assertEqual((niri / 'dms/outputs.kdl').read_text(), 'machine outputs\n')
        self.assertEqual(json.loads(settings.read_text()), {'untouched': True})
        self.assertNotIn('colors.kdl', self.git('status', '--porcelain'))
        self.make('check')

    def test_atomic_gui_saves_change_git_and_survive_redeployment(self):
        self.make('stow')
        edits = {
            '.config/dms/config.d/10-preferences.json': '{"clockFormat":"24h"}\n',
            '.config/niri/dms/binds.kdl': 'binds { Mod+T { spawn \"alacritty\"; }; }\n',
        }
        for relative, contents in edits.items():
            path = self.home / relative
            temporary = path.with_suffix('.tmp')
            temporary.write_text(contents)
            os.replace(temporary, path)
            self.assertFalse(path.is_symlink())
            self.assertEqual((self.repo / 'home' / relative).read_text(), contents)
        self.assertEqual(set(self.git('diff', '--name-only').splitlines()),
                         {'home/' + relative for relative in edits})
        self.make('stow')
        alias = self.root / 'checkout-alias'
        alias.symlink_to(self.repo, target_is_directory=True)
        subprocess.run(['bash', str(alias / 'scripts/link-desktop.sh'), 'link', str(self.home)], check=True)
        self.make('check')
        for relative, contents in edits.items():
            self.assertEqual((self.home / relative).read_text(), contents)
        self.make('unstow')
        self.assertFalse((self.home / '.config/niri').is_symlink())
        self.assertFalse((self.home / '.config/dms/config.d').is_symlink())
        for relative, contents in edits.items():
            self.assertEqual((self.repo / 'home' / relative).read_text(), contents)


if __name__ == '__main__':
    unittest.main()
