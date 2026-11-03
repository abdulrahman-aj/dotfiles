"""Exercise desktop deployment with the repository's ordinary Stow behavior."""
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]


class DesktopDeployment(unittest.TestCase):
    def test_file_links_preserve_edits_and_leave_runtime_files_in_target(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            repo = root / 'dotfiles'
            shutil.copytree(SOURCE, repo, ignore=shutil.ignore_patterns('.git', '__pycache__'))
            home = root / 'home'
            niri = home / '.config/niri'
            (niri / 'dms').mkdir(parents=True)
            (niri / 'config.kdl').write_text('old config\n')
            colors = niri / 'dms/colors.kdl'
            colors.write_text('runtime colors\n')
            settings = home / '.config/dms/settings.json'
            settings.parent.mkdir()
            settings.write_text('{"untouched":true}')
            fragments = settings.parent / 'config.d'
            fragments.mkdir()
            (fragments / 'personal.json').write_text('{"keep":true}')
            agents = root / 'agents'
            agents.mkdir()
            (agents / 'Makefile').write_text('check uninstall:\n\t@true\n')

            def make(target):
                subprocess.run(['make', '-s', target, f'TARGET={home}',
                                f'AGENT_CONFIG_DIR={agents}'], cwd=repo,
                               check=True, stdout=subprocess.DEVNULL)

            make('stow')
            for directory in (niri, niri / 'dms', fragments):
                self.assertFalse(directory.is_symlink())
            files = ['.config/niri/config.kdl', '.config/niri/dms/binds.kdl',
                     '.config/niri/dms/windowrules.kdl', '.config/niri/dms/layout.kdl',
                     '.config/dms/config.d/10-preferences.json',
                     '.config/dms/config.d/20-niri.json']
            for relative in files:
                path = home / relative
                self.assertTrue(path.is_symlink())
                self.assertEqual(path.resolve(), repo / 'home' / relative)
            backups = list((home / '.dotfiles-backups').glob('*/.config/niri/config.kdl'))
            self.assertEqual([p.read_text() for p in backups], ['old config\n'])
            preferences = fragments / '10-preferences.json'
            preferences.write_text('{"clockFormat":"24h"}\n')
            make('stow')
            make('check')
            self.assertTrue(preferences.is_symlink())
            self.assertEqual(json.loads(preferences.read_text()), {'clockFormat': '24h'})
            self.assertEqual(json.loads(settings.read_text()), {'untouched': True})
            self.assertEqual(json.loads((fragments / 'personal.json').read_text()), {'keep': True})
            self.assertEqual(colors.read_text(), 'runtime colors\n')
            self.assertFalse((repo / 'home/.config/niri/dms/colors.kdl').exists())
            make('unstow')
            for relative in files:
                self.assertFalse((home / relative).is_symlink())
            self.assertEqual(colors.read_text(), 'runtime colors\n')
            self.assertEqual(json.loads((repo / 'home/.config/dms/config.d/10-preferences.json').read_text()),
                             {'clockFormat': '24h'})


if __name__ == '__main__':
    unittest.main()
