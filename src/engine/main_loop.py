from loguru import logger
import os
import sys
LOGGING_LEVEL = os.environ.get('LOGURU_LEVEL', 'INFO')
logger.remove()
logger.add(sys.stdout, level=LOGGING_LEVEL)