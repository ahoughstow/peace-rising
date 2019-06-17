# peace-rising
Code base for Peace Rising data analysis


## In this Repository: 
amber-syria: Amber's previous work on the Syria dataset (in R), placed here for easy access and reference. A detailed description of her previous work can be found here: http://peace-rising.org/wiki/prior-work/

conflict-analysis : This folder is made for the geographical conflict analysis project.

## Querying Data:
Currently, all of our data is stored in an Amazon RDS database by the name learningdb. Everything we currently have has now been uploaded there, with the exception of the GDELT database, which is available through Google BigQuery. 

Addition information about the dataset can be found on the wiki here: http://peace-rising.org/wiki/data-access-and-documentation/

#### Server information: 

| Field    | Content                                                   |
|----------|-----------------------------------------------------------|
| Name     | A descriptive name such as "PR PostGIS"                   |
| Service  | Leave blank                                               |
| Host     | learninginstance.czgwzgnu0eed.us-east-1.rds.amazonaws.com |
| Port     | 5432 (default)                                            |
| Database | learningdb                                                |

Below, we have included instructions on setting up for querying data. 

### Setting up (Ubuntu 18) 
First, make sure your computer is in a place capable of connecting to the database. If not, find your IP address and add it to the security rules for the server. 

A potential problem might arise if you have not updated in a while. If so, this can be solved by running the following: 
```
sudo apt-get update                 # Fetches list of available upgrades
sudo apt-get upgrade                # Strictly upgrades current packages
sudo apt-get dist-upgrade           # Installs updates
```

Another potential problem is your Python version - check that it is the latest version.

Next, set up a virtual environment for your work. In the terminal, type 
`python3 -m pip install --user virtualenv` and name it using the command `python3 -m virtualenv $YOUR_NAME_HERE`. Your virtual environment can be summoned in the future by the command `source $YOUR_NAME_HERE/bin/activate`. 

Next, we wish to install pands and pymysql, which will help with data wrangling. 
```
sudo apt-get install python3-pandas         # installs pandas
python3 -m pip install PyMySQL              # installs PyMySQL
```
To check for correct installation, run
```
python -c "import math"
echo $?
```
If it returns a number instead of an error message, you are up and running. 
The following packages will also need to be installed in order to work with geospatial data: simplejson, psycopg2, numpy, requests, geopy. They can all be installed with pip. 

### Connecting to the database
Access the python shell by typing `python` in the command line. To connect to the server, run the following lines of code:
```
conn = psycopg2.connect("dbname='learningdb' user='Aerith' password='Pl4n3t34rth' host='learninginstance.czgwzgnu0eed.us-east-1.rds.amazonaws.com' port='5432'")
```
If no error message appears, you should be connected to the server. 

### Exploring the database
First, type the following into the terminal: 
`psql -U Aerith -h learninginstance.czgwzgnu0eed.us-east-1.rds.amazonaws.com -p 5432 learningdb`
Your terminal prompt should now look like `learningdb=>`, which means that you are now ready to explore the database. Below are a few useful commands to get started. 

| Handy Commands                  | Description                                                                                                                          |
|---------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| \dt                             | shows first 10 tables and their schemas, starting with the public schema                                                             |
| .\dn                            | shows list of all the schemas                                                                                                        |
| q                               | stops viewing of the schema list                                                                                                     |
| \dt "Conflict".*                | look up tables in a schema - in this case, the Conflict schema. Use quotes around the schema name if your schema has capital letters |
| \d "Conflict"."Conf_AC"         | shows all column headers in table Conf_ACD                                                                                           |
| SELECT c1, c2 FROM t            | Query data from columns c1, c2 from table t                                                                                          |
| SELECT * FROM t                 | Select all data from table t                                                                                                         |
| SELECT * FROM t WHERE year=2010 | Select all data that matches condition year=2010      

There should be resources available online for other commands. 

### Uploading a raster file 


First, navigate to the directory where your raster file intended for upload is stored. Then, from inside that directory, type the following into the terminal:
```
raster2pgsql -s 4269 -t 100x100 -F -I -C -Y landcover.img public.test_raster | psql -U Aerith -h learninginstance.czgwzgnu0eed.us-east-1.rds.amazonaws.com -p 5432 learningdb 
```
In the above exampe, the test file, `landcover.img`, was added to a test location, `public.teset_raster`. In your commands, these can be changed to match the file you are uploading and the location you want to send them to. 
