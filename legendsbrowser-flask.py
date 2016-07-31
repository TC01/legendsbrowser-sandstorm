#!/usr/bin/env python

"""legendsbrowser-flask.py - a small flask application to sit in front of and execute
Legends Browser when a user uploads legends information to it.

Legends Browser is a cross-platform Dwarf Fortress legends viewer,
https://github.com/robertjanetzko/LegendsBrowser

Copyright (C) 2016 Ben Rosser ("TC01")

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import os
from flask import Flask, request, redirect, url_for
from werkzeug.utils import secure_filename
from werkzeug.contrib.fixers import ProxyFix

import argparse
import logging
import shutil
import socket
import subprocess
import sys
import time
import zipfile

UPLOAD_FOLDER = os.path.expanduser(os.path.join("~", ".local", "share", "legendsbrowser-flask"))
ALLOWED_EXTENSIONS = set(['zip'])

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app)

# Interval to wait between launching legends browser and redirecting to it
wait_interval = 5 # seconds

# Set globally at startup, this is hackish but works.
global lburl
lburl = None

def allowed_file(filename):
	return '.' in filename and filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

def extract_archive(path):
	if path.rsplit('.', 1)[1] == 'zip':
		archive = zipfile.ZipFile(path, 'r')
		archive.extractall(app.config['UPLOAD_FOLDER'])
	return find_legendsxml(app.config['UPLOAD_FOLDER'])

def find_legendsxml(search):
	for path, dirs, files in os.walk(search):
		for filename in files:
			if filename.endswith("legends.xml"):
				return os.path.join(path, filename)
	return None

def spawn_legendsbrowser(xmlpath):
	# Test if legendsbrowser's socket is taken.
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	result = sock.connect_ex(('127.0.0.1', 58881))
	if result != 0:
		subprocess.Popen(["legendsbrowser", "-w", xmlpath, "-s", "-u", "/legends"])

@app.route('/', methods=['GET', 'POST'])
def upload_file():

#	lburl = request.url + "/legends"
#	lburl = lburl.replace("http:", "https:")

	# If find_legendsxml returns true, don't bother with the uploader.
	if request.method == 'GET':
		xmlpath = find_legendsxml(app.config['UPLOAD_FOLDER'])
		if xmlpath is not None:
			spawn_legendsbrowser(xmlpath)
			time.sleep(wait_interval)
			return redirect(lburl)

	app.logger.warning("Redirect form of the legendsbrowser URL is: " + str(redirect(lburl)))
	app.logger.warning("Current request URL was: " + str(request.url))
	app.logger.warning("Redirect of that URL was: " + str(redirect(request.url)))
	if request.method == 'POST':
		# check if the post request has the file part
		if 'file' not in request.files:
			flash('No file part')
			return redirect(request.url)
		file = request.files['file']
		# if user does not select file, browser also
		# submit a empty part without filename
		if file.filename == '':
			flash('No selected file')
			return redirect(request.url)
		if file and allowed_file(file.filename):
			filename = secure_filename(file.filename)
			path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
			file.save(path)

			# Extract the archive file, returns path to legends.xml
			# If we find it, spawn legendsbrowser in a subprocess
			# This assumes legendsbrowser is installed systemwide
			xmlpath = extract_archive(path)
			if xmlpath is None:
				return redirect(url_for('uploaded_file',filename=filename))
			else:
				# XXX: need to pass port here too.
				spawn_legendsbrowser(xmlpath)
				time.sleep(wait_interval)
				return redirect(lburl)
	else:
	# We really should stick this in a template, but I am lazy.
		return '''
    <!doctype html>
    <title>Legends Browser Uploader</title>
    <h1>Legends Browser Uploader</h1>
	This app lets you upload legends data from a <a href="http://www.bay12games.com/dwarves/">Dwarf Fortress</a>
	world and render it using <a href="https://github.com/robertjanetzko/LegendsBrowser">Legends Browser</a>.
	You can view the history of your world outside the game and share it with your friends!

	</br></br>
	To begin, from inside Dwarf Fortress, open Legends mode and export your data: you must at least create
	an XML dump. The files will be created inside the root of your Dwarf Fortress installation.

	</br></br>
	Once you have dumped your Legends data, compress all the legends files into a zip archive and upload it
	using the form below. Note that the zip must include one file ending in "legends.xml"; this is the main
	XML dump of your world data. Legends Browser will then run.
	Please note that you may need to refresh the page if it does not auto-refresh to load Legends Browser.

	</br></br>

	To upload additional legends data, you currently must make an entirely new grain.

    <form action="" method=post enctype=multipart/form-data>
      <p><input type=file name=file>
         <input type=submit value="Upload">
    </form>
    '''

if __name__ == '__main__':

	# Set up argument parser
	parser = argparse.ArgumentParser()
	parser.add_argument("-d", "--directory", dest="directory", default=UPLOAD_FOLDER, help="Directory to upload and store legends files.")
	parser.add_argument("-c", "--clean", dest="clean", action="store_true", help="Clean the upload directory before doing anything.")
	parser.add_argument("-l", "--lb-url", dest="lburl", default="/legends", help="The URL to redirect to when loading LegendsBrowser.")
	args = parser.parse_args()

	# If told to clean, try to first delete the directory.
	# Then make directory if it does not already exist.
	directory = os.path.abspath(os.path.expanduser(args.directory))
	if args.clean and os.path.exists(directory):
		shutil.rmtree(directory)
	if not os.path.exists(directory):
		os.makedirs(directory)

	# Set the lburl.
	# I am not totally sure what this should be.
	# When running from sandstorm, probably /legendsbrowser or something like that
	# Otherwise, it needs to know the port to redirect to
	lburl = args.lburl

	# set logging information
	logger = logging.StreamHandler(sys.stdout)
	logger.setLevel(logging.INFO)
	app.logger.addHandler(logger)

	app.config['UPLOAD_FOLDER'] = directory
	app.run(host = '0.0.0.0')
