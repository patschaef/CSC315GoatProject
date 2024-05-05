#! /usr/bin/python3

"""
This is an example Flask | Python | Psycopg2 | PostgreSQL
application that connects to the 7dbs database from Chapter 2 of
_Seven Databases in Seven Weeks Second Edition_
by Luc Perkins with Eric Redmond and Jim R. Wilson.
The CSC 315 Virtual Machine is assumed.

John DeGood
degoodj@tcnj.edu
The College of New Jersey
Spring 2020

----

One-Time Installation

You must perform this one-time installation in the CSC 315 VM:

# install python pip and psycopg2 packages
sudo pacman -Syu
sudo pacman -S python-pip python-psycopg2 python-flask

----

Usage

To run the Flask application, simply execute:

export FLASK_APP=app.py 
flask run
# then browse to http://127.0.0.1:5000/

----

References

Flask documentation:  
https://flask.palletsprojects.com/  

Psycopg documentation:
https://www.psycopg.org/

This example code is derived from:
https://www.postgresqltutorial.com/postgresql-python/
https://scoutapm.com/blog/python-flask-tutorial-getting-started-with-flask
https://www.geeksforgeeks.org/python-using-for-loop-in-flask/
"""

import psycopg2
from config import config
from flask import Flask, render_template, request

# Connect to the PostgreSQL database server
def connect(query):
    conn = None
    try:
        # read connection parameters
        params = config()
 
        # connect to the PostgreSQL server
        print('Connecting to the %s database...' % (params['database']))
        conn = psycopg2.connect(**params)
        print('Connected.')
      
        # create a cursor
        cur = conn.cursor()
        
        # execute a query using fetchall()
        cur.execute(query)
        rows = cur.fetchall()

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    # return the query result from fetchall()
    return rows
 
# app.py
app = Flask(__name__)


# serve form web page
@app.route("/")
def form():
    return render_template('my-form.html')

# handle venue POST and serve result web page

@app.route('/top_moms', methods=['POST'])
def top_moms():
    rows = connect('select * from scores order by Total_Mother_Score DESC LIMIT 30;')
    heads = ['mother tag','Animal_id', 'Mother Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/bottom_moms', methods=['POST'])
def bottom_moms():
    rows = connect('select * from scores order by Total_Mother_Score LIMIT 30;')
    heads = ['mother tag','Animal_id', 'Mother Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/all_moms', methods=['POST'])
def all_moms():
    rows = connect('select * from scores order by Total_Mother_Score DESC;')
    heads = ['mother tag','Animal_id', 'Mother Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/momgoats', methods=['POST'])
def momgoats():
    rows = connect('SELECT b.tag, a.tag, a.kid_sco FROM (kid NATURAL JOIN child) a LEFT JOIN (kid NATURAL JOIN child) b ON b.tag=a.dam WHERE b.tag = \'' + request.form['query'] + '\';')
    heads = ['Doe Tag', 'Kid Tag','Score from Kid']
    return render_template('my-result.html', rows=rows,heads=heads)

# goat astrology    

@app.route('/aquarius', methods=['POST'])
def aquarius():
    rows = connect('SELECT tag ,dob, kid_sco FROM astrology WHERE ((EXTRACT(MONTH FROM dob) = 1 AND EXTRACT(DAY FROM dob) >= 20) OR (EXTRACT(MONTH from dob) = 2 AND EXTRACT(DAY from dob) <= 18));')
    heads = ['tag' ,'Aquarius DOB', 'Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/Pisces', methods=['POST'])
def Pisces():
    rows = connect('SELECT tag, dob, kid_sco FROM astrology WHERE((EXTRACT(MONTH FROM dob) = 2 AND EXTRACT(DAY FROM dob) >18) OR (EXTRACT(MONTH from dob) = 3 AND EXTRACT(DAY from dob) <= 20));')
    heads = ['tag' ,'Pisces DOB', 'Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/Aries', methods=['POST'])
def Aries():
    rows = connect('SELECT tag, dob, kid_sco FROM astrology WHERE((EXTRACT(MONTH FROM dob) = 3 AND EXTRACT(DAY FROM dob) >20) OR (EXTRACT(MONTH from dob) = 4 AND EXTRACT(DAY from dob) <= 19)) ;')
    heads = ['tag' ,'Aries DOB', 'Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/Taurus', methods=['POST'])
def Taurus():
    rows = connect('SELECT tag dob, kid_sco FROM astrology WHERE((EXTRACT(MONTH FROM dob) = 4 AND EXTRACT(DAY FROM dob) > 19) OR (EXTRACT(MONTH from dob) = 5 AND EXTRACT(DAY from dob) <= 20)) ;')
    heads = ['tag' ,'Taurus DOB', 'Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/Gemini', methods=['POST'])
def Gemini():
    rows = connect('SELECT tag,dob, kid_sco FROM astrology WHERE((EXTRACT(MONTH FROM dob) = 5 AND EXTRACT(DAY FROM dob) >20) OR (EXTRACT(MONTH from dob) = 6 AND EXTRACT(DAY from dob) <= 20)) ;')
    heads = ['tag' ,'Gemini DOB', 'Score']
    return render_template('my-result.html', rows=rows, heads=heads)

@app.route('/Cancer', methods=['POST'])
def Cancer():
    rows = connect('SELECT tag, dob, kid_sco FROM astrology WHERE((EXTRACT(MONTH FROM dob) = 6 AND EXTRACT(DAY FROM dob) > 20) OR (EXTRACT(MONTH from dob) = 7 AND EXTRACT(DAY from dob) <= 22)) ;')
    heads = ['tag' ,'Cancer DOB', 'Score']
    return render_template('my-result.html', rows=rows, heads=heads)




# the query doesnt want to handle the  AND BWT <> '' to get rid of the clear bwt's
# handle query POST and serve result web page
@app.route('/query-handler', methods=['POST'])
def query_handler():
    rows = connect(request.form['query'])
    return render_template('my-result.html', rows=rows)

if __name__ == '__main__':
    app.run(debug = True)
