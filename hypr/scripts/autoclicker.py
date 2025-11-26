#!/home/warre/.config/hypr/scripts/.venv/bin/python
"""
Auto Clicker Script - Controlled via command-line arguments
Usage:
    autoclicker.py start    - Start the auto clicker daemon
    autoclicker.py stop     - Stop the auto clicker daemon
    autoclicker.py toggle   - Toggle the auto clicker on/off
    autoclicker.py status   - Check if auto clicker is running
"""

import os
import signal
import sys
import time

from pynput.mouse import Button
from pynput.mouse import Controller as MouseController

# Configuration
CLICK_INTERVAL = 1.0  # Time between clicks in seconds (0.1 = 10 clicks per second)
MOUSE_BUTTON = Button.left  # Which mouse button to click (Button.left or Button.right)

# File paths for state management
PID_FILE = "/tmp/autoclicker.pid"
ACTIVE_FILE = "/tmp/autoclicker.active"


def get_pid():
    """Get the PID of the running autoclicker daemon."""
    if os.path.exists(PID_FILE):
        with open(PID_FILE, "r") as f:
            try:
                return int(f.read().strip())
            except ValueError:
                return None
    return None


def is_running():
    """Check if the autoclicker daemon is running."""
    pid = get_pid()
    if pid:
        try:
            os.kill(pid, 0)  # Check if process exists
            return True
        except OSError:
            # Process doesn't exist, clean up stale files
            cleanup()
    return False


def is_active():
    """Check if the autoclicker is actively clicking."""
    return os.path.exists(ACTIVE_FILE)


def cleanup():
    """Remove PID and active files."""
    for f in [PID_FILE, ACTIVE_FILE]:
        if os.path.exists(f):
            os.remove(f)


def start_daemon():
    """Start the autoclicker daemon."""
    if is_running():
        print("Auto clicker is already running!")
        return

    # Fork to create daemon
    pid = os.fork()
    if pid > 0:
        # Parent process
        print(f"Auto clicker daemon started (PID: {pid})")
        return

    # Child process (daemon)
    os.setsid()

    # Write PID file
    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

    # Set up signal handler for clean shutdown
    def signal_handler(signum, frame):
        cleanup()
        sys.exit(0)

    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    # Main clicking loop
    mouse = MouseController()
    while True:
        if is_active():
            mouse.click(MOUSE_BUTTON)
            time.sleep(CLICK_INTERVAL)
        else:
            time.sleep(0.05)  # Small sleep to prevent CPU hogging


def stop_daemon():
    """Stop the autoclicker daemon."""
    pid = get_pid()
    if pid:
        try:
            os.kill(pid, signal.SIGTERM)
            print("Auto clicker stopped.")
        except OSError:
            print("Auto clicker was not running.")
        cleanup()
    else:
        print("Auto clicker is not running.")
        cleanup()


def toggle():
    """Toggle the autoclicker on/off."""
    if not is_running():
        print("Auto clicker daemon is not running. Start it first with 'start'.")
        # Auto-start the daemon
        start_daemon()
        time.sleep(0.1)  # Give daemon time to start

    if is_active():
        os.remove(ACTIVE_FILE)
        os.system("notify-send -t 1000 'Auto Clicker' 'OFF'")
        print("Auto clicker: OFF")
    else:
        with open(ACTIVE_FILE, "w") as f:
            f.write("1")
        os.system("notify-send -t 1000 'Auto Clicker' 'ON'")
        print("Auto clicker: ON")


def status():
    """Print the current status of the autoclicker."""
    if is_running():
        if is_active():
            print("Auto clicker: RUNNING (clicking)")
        else:
            print("Auto clicker: RUNNING (paused)")
    else:
        print("Auto clicker: NOT RUNNING")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == "start":
        start_daemon()
    elif command == "stop":
        stop_daemon()
    elif command == "toggle":
        toggle()
    elif command == "status":
        status()
    else:
        print(f"Unknown command: {command}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
