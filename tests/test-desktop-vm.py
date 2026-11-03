"""Check real Dux writers in a disposable Niri VM with this checkout deployed.

Run as the graphical-session user: make test-desktop-vm ARGS=--disposable-vm
This changes preferences, adds a binding/rule, and redeploys configuration.
After restarting the VM/session, rerun with ARGS='--disposable-vm --check-only'.
"""
import argparse
import json
from pathlib import Path
import subprocess
import time


def run(*command):
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
    if result.returncode:
        raise RuntimeError(f'{command!r} failed:\n{result.stdout}')
    return result.stdout.strip()


def wait_for(check):
    deadline = time.monotonic() + 20
    while time.monotonic() < deadline:
        if check():
            return
        time.sleep(0.2)
    raise AssertionError('Dux did not persist the expected settings within 20 seconds')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disposable-vm', action='store_true', help='Confirm this is a disposable VM')
    parser.add_argument('--check-only', action='store_true', help='Check persistence without changing settings')
    args = parser.parse_args()
    if not args.disposable_vm:
        parser.error('Run only in a disposable VM, with --disposable-vm')
    virtualization = subprocess.run(['systemd-detect-virt', '--vm'], capture_output=True, text=True)
    if virtualization.returncode:
        parser.error('Refusing to change a desktop outside a detected virtual machine')
    repo = Path(__file__).resolve().parents[1]
    home = Path.home()
    relative = [
        '.config/dms/config.d/10-preferences.json',
        '.config/dms/config.d/20-niri.json',
        '.config/niri/dms/binds.kdl',
        '.config/niri/dms/windowrules.kdl',
        '.config/niri/dms/layout.kdl',
    ]

    def check_links():
        for name in relative:
            path = home / name
            assert path.is_symlink(), f'File link was replaced: {path}'
            assert path.resolve() == repo / 'home' / name, f'Unexpected link target: {path}'

    def settings_match():
        clock = json.loads((home / relative[0]).read_text())
        niri = json.loads((home / relative[1]).read_text())
        return (clock.get('clockFormat') == '24h'
                and niri.get('niriLayoutGapsOverride') == 18)

    check_links()
    if not args.check_only:
        for key, value in [('clockFormat', '24h'), ('niriLayoutGapsOverride', '18')]:
            assert 'SETTINGS_SET_SUCCESS' in run('dms', 'ipc', 'call', 'settings', 'set', key, value)
        assert json.loads(run('dms', 'keybinds', 'set', 'niri', 'Mod+T', 'spawn alacritty'))['success']
        rule = {'id': 'dotfiles-vm-probe', 'name': 'Dotfiles VM probe',
                'matchCriteria': {'appId': '^dotfiles-vm-probe$'}, 'actions': {'openFloating': True}}
        assert json.loads(run('dms', 'config', 'windowrules', 'add', 'niri', json.dumps(rule)))['success']
        wait_for(settings_match)
        before = {name: (home / name).read_bytes() for name in relative}
        run('make', '-s', '-C', str(repo), 'stow', f'TARGET={home}')
        assert before == {name: (home / name).read_bytes() for name in relative}, 'Redeployment changed preferences'

    wait_for(settings_match)
    check_links()
    if args.check_only:
        assert 'gaps 18' in (home / relative[4]).read_text(), 'Reboot did not regenerate layout'
    assert json.loads(run('dms', 'ipc', 'call', 'settings', 'get', 'clockFormat')) == '24h'
    assert json.loads(run('dms', 'ipc', 'call', 'settings', 'get', 'niriLayoutGapsOverride')) == 18
    assert 'Mod+T' in (home / relative[2]).read_text()
    assert 'dotfiles-vm-probe' in (home / relative[3]).read_text()
    for name in ('input', 'cursor', 'alttab'):
        runtime = home / f'.config/niri/dms/{name}.kdl'
        assert runtime.is_file() and not runtime.is_symlink(), f'Unexpected runtime path: {runtime}'
        assert not (repo / f'home/.config/niri/dms/{name}.kdl').exists()
    run('niri', 'validate', '-c', str(home / '.config/niri/config.kdl'))
    changed = set(run('git', '-C', str(repo), '--no-pager', 'diff', '--name-only').splitlines())
    expected = {'home/' + name for name in relative}
    assert changed == expected, f'Unexpected Git changes: {changed}'
    print(json.dumps({'file_links_preserved': True, 'preferences_verified': True,
                      'git_changes': sorted(changed), 'check_only': args.check_only}, indent=2))


if __name__ == '__main__':
    main()
