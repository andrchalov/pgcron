#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import select
import psycopg2
from psycopg2 import sql
import logging
import os
import time

PG_CHANNEL = 'pgcron'
logger = logging.getLogger("main")
logging.basicConfig(stream=sys.stdout, level=os.getenv('LOGLEVEL', 'INFO'))

conn = psycopg2.connect("")
conn.autocommit = True

curs = conn.cursor()

logging.debug("Start listening channel %s" % PG_CHANNEL)
curs.execute(sql.SQL('LISTEN {};').format(sql.Identifier(PG_CHANNEL)))

payload = None

while True:
  logging.debug(u'Fetching new job, payload: %s' % payload)
  curs.execute('SELECT pgcron.run(%s)', (payload,))
  payload = None
  resp = curs.fetchone()

  if resp and resp[0] == True:
    logging.debug(u'Job has been completed, check again')
    continue
  else:
    logging.debug(u'No jobs found')

  wait = True
  while wait:
    logging.debug("Waiting for notifications on channel %s" % PG_CHANNEL)
    if select.select([conn],[],[],30) == ([],[],[]):
      logging.debug(u'Waiting timeout')
      wait = False
    else:
      conn.poll()
      while conn.notifies:
        notify = conn.notifies.pop(0)
        logging.debug(u'Getting notification %s, payload: %s', notify.channel, notify.payload)
        payload = notify.payload
        wait = False
        break
