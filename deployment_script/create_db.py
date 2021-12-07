#!/usr/bin/python3

import psycopg2
import os

DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

#establishing the connection
conn = psycopg2.connect(
   database="postgres", user=DB_USER, password=DB_PASSWORD, host=DB_HOST, port= '5432'
)
conn.autocommit = True

#Creating a cursor object using the cursor() method
cursor = conn.cursor()

cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{}'".format(DB_NAME))
exists = cursor.fetchone()
if not exists:
    print("db does not exist")
    cursor.execute('CREATE DATABASE {}'.format(DB_NAME))
else:
    print("db {} already exists".format(DB_NAME))

#Closing the connection
conn.close()