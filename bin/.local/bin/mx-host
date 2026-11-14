#!/usr/bin/env python3
"""
mx-host — show and switch the MX Master 4's Easy-Switch channel.

Speaks HID++ to the mouse's hidraw node: feature 0x1814 (CHANGE_HOST) reads and
switches the channel, 0x1815 (HOSTS_INFO) gives the paired computers' names.
Access without root comes from mx-master/etc/udev/rules.d/70-mx-master-hidraw.rules.

Usage:
  mx-host status [--json]
  mx-host switch 1|2|3|next|prev
"""
import glob
import json
import os
import select
import subprocess
import sys
import time

CHANGE_HOST = 0x1814
HOSTS_INFO = 0x1815
SOFTWARE_ID = 0x0B
DEVICE_INDEX = 0xFF  # Bluetooth-connected device
HID_ID = 'HID_ID=0005:0000046D:0000B042'  # Bluetooth, Logitech, MX Master 4

CACHE = os.path.join(os.environ.get('XDG_CACHE_HOME', os.path.expanduser('~/.cache')), 'mx-host.json')
NOTIFICATION_ID = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'mx-host-notif-id')

HidppError = (OSError, TimeoutError, RuntimeError)


class Unreachable(Exception):
    pass


class Mouse:
    """An open HID++ connection to the MX Master 4. Use as a context manager."""

    def __init__(self):
        nodes = self._hidraw_nodes()
        if not nodes:
            raise Unreachable('not connected to this computer')
        reason = 'the mouse did not answer'
        for node in nodes:
            try:
                self.fd = os.open(node, os.O_RDWR)
            except PermissionError:
                reason = f'no permission on {node} (is 70-mx-master-hidraw.rules installed?)'
                continue
            except OSError as e:
                reason = str(e)
                continue
            try:
                self.change_host = self._feature_index(CHANGE_HOST)
                if self.change_host:
                    return
                reason = 'the mouse has no Easy-Switch feature'
            except HidppError as e:
                reason = str(e)
            os.close(self.fd)
        raise Unreachable(reason)

    def __enter__(self):
        return self

    def __exit__(self, *_):
        os.close(self.fd)

    @staticmethod
    def _hidraw_nodes():
        nodes = []
        for uevent in sorted(glob.glob('/sys/class/hidraw/hidraw*/device/uevent')):
            try:
                with open(uevent) as f:
                    if HID_ID in f.read():
                        nodes.append('/dev/' + uevent.split('/')[4])
            except OSError:
                pass
        return nodes

    def _request(self, feature, function, params=b'', reply=True):
        tag = (function << 4) | SOFTWARE_ID
        os.write(self.fd, bytes([0x11, DEVICE_INDEX, feature, tag, *params]).ljust(20, b'\0'))
        if not reply:
            return b''
        deadline = time.time() + 1.5
        while time.time() < deadline:
            if not select.select([self.fd], [], [], 0.2)[0]:
                continue
            report = os.read(self.fd, 64)
            if len(report) < 6 or report[0] != 0x11 or report[1] != DEVICE_INDEX:
                continue
            if report[2:5] == bytes([0xFF, feature, tag]):
                raise RuntimeError(f'HID++ error {report[5]:#x}')
            if report[2:4] == bytes([feature, tag]):
                return report[4:]
        raise TimeoutError('the mouse did not answer')

    def _feature_index(self, feature):
        return self._request(0x00, 0, feature.to_bytes(2, 'big'))[0]

    def channels(self):
        """(channel count, current channel), channels numbered from 1."""
        info = self._request(self.change_host, 0)
        return info[0], info[1] + 1

    def switch_to(self, channel):
        # The mouse drops this connection immediately, so no reply comes back.
        self._request(self.change_host, 1, [channel - 1], reply=False)

    def names(self, count):
        """{'1': name, ...} of the paired computers; {} when the mouse can't tell."""
        try:
            hosts_info = self._feature_index(HOSTS_INFO)
            if not hosts_info or not self._request(hosts_info, 0)[0] & 0x01:
                return {}
            names = {}
            for host in range(count):
                info = self._request(hosts_info, 1, [host])
                paired, length = info[1], info[4]
                name = b''
                while paired and len(name) < length:
                    chunk = self._request(hosts_info, 3, [host, len(name)])[2:2 + min(14, length - len(name))]
                    if not chunk:
                        break
                    name += chunk
                names[str(host + 1)] = name.split(b'\0')[0].decode('utf-8', 'replace').strip()
            return names
        except HidppError:
            return {}


def load_cache():
    try:
        with open(CACHE) as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except (OSError, ValueError):
        return {}


def save_cache(**data):
    try:
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        with open(CACHE + '.new', 'w') as f:
            json.dump(data, f)
        os.replace(CACHE + '.new', CACHE)
    except OSError:
        pass


def notify(title, body, icon='input-mouse'):
    replace = []
    try:
        with open(NOTIFICATION_ID) as f:
            previous = f.read().strip()
        if previous.isdigit():
            replace = ['-r', previous]
    except OSError:
        pass
    try:
        new_id = subprocess.run(
            ['notify-send', '-p', *replace, '-a', 'MX Master 4', '-i', icon, '-u', 'normal', '-t', '4000', title, body],
            capture_output=True, text=True, timeout=5).stdout.strip()
        if new_id.isdigit():
            with open(NOTIFICATION_ID, 'w') as f:
                f.write(new_id)
    except (OSError, subprocess.SubprocessError):
        pass


def label(names, channel):
    name = names.get(str(channel), '')
    return f'{channel} · {name}' if name else str(channel)


def status():
    """Live state while the mouse is here; the cached channel list while it is away."""
    cache = load_cache()
    state = {
        'connected': False,
        'current': None,
        'count': cache.get('count', 3),
        'names': cache.get('names', {}),
        'here': cache.get('here'),
        'awayTo': cache.get('awayTo'),
        'error': '',
    }
    try:
        with Mouse() as mouse:
            count, current = mouse.channels()
            # Names only change on re-pairing, so read them once per channel layout.
            if not state['names'] or cache.get('count') != count or cache.get('here') != current:
                state['names'] = mouse.names(count) or state['names']
    except (Unreachable, *HidppError) as e:
        state['error'] = str(e)
        return state
    state.update(connected=True, count=count, current=current, here=current, awayTo=None)
    save_cache(count=count, names=state['names'], here=current)
    return state


def switch(target):
    try:
        with Mouse() as mouse:
            count, current = mouse.channels()
            if target == 'next':
                channel = current % count + 1
            elif target == 'prev':
                channel = (current - 2) % count + 1
            else:
                channel = int(target)
            if not 1 <= channel <= count:
                notify('MX Master 4', f'There is no channel {channel} (1–{count}).', 'dialog-warning')
                return 2
            names = load_cache().get('names') or mouse.names(count)
            if channel == current:
                notify('MX Master 4', f'Already on this computer ({label(names, channel)}).')
                return 0
            notify(f'MX Master 4 → device {channel}', f'Moved to {label(names, channel)}.')
            mouse.switch_to(channel)
    except Unreachable as e:
        notify('MX Master 4 is not here', f'Cannot switch it: {e}.', 'dialog-warning')
        return 1
    except HidppError as e:
        notify('MX Master 4 switch failed', str(e), 'dialog-error')
        return 1
    save_cache(count=count, names=names, here=current, awayTo=channel)
    return 0


def main():
    args = sys.argv[1:] or ['status']
    if args[0] == 'status':
        state = status()
        if '--json' in args:
            print(json.dumps(state))
        elif state['connected']:
            print(f'here, on channel {label(state["names"], state["current"])} of {state["count"]}')
        else:
            print(f'away ({state["error"]})')
        return 0
    if args[0] == 'switch' and len(args) == 2 and (args[1].isdigit() or args[1] in ('next', 'prev')):
        return switch(args[1])
    print(__doc__.split('Usage:')[1].rstrip(), file=sys.stderr)
    return 2


if __name__ == '__main__':
    sys.exit(main())
