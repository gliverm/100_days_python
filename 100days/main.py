"""
Sample CLI appliation

To execute with dev environment:
export PYTHONPATH=${PYTHONPATH}:${PWD}
python app/main.py --help
"""
import sys
import typer

from app.lib.base_logger import getlogger

LOGGER = getlogger(__name__)

app = typer.Typer(
    add_completion=False,
    context_settings={"help_option_names": ["-h", "--help"]},
)
if __name__ == "__main__":
    try:
        app()
    except KeyboardInterrupt:
        LOGGER.info("Keyboard interrupt - exiting")
        sys.exit(1)
