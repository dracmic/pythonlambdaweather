import sys
import os
import logging
import requests,json
import boto3

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.INFO)

def get_weather():
    #api key obtained for openweathermap
    api_key = os.environ.get('API_KEY')
    #location to pull
    city_name_lat_long =  os.environ.get('Location')
    s3_bucket = os.environ.get('s3_bucket')
    #http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}  
    #For specific weather conditions of the specified location we need to query for longitude and latitude of the location
    base_url_geocoding = "http://api.openweathermap.org/geo/1.0/direct?q="
    complete_url_geocoding = base_url_geocoding + city_name_lat_long + "&limit=1" + "&appid=" + api_key
    LOGGER.info('Getting latitude and longitute for: %s', city_name_lat_long)
    response_geocoding = requests.get(complete_url_geocoding)
    lat_long = response_geocoding.json()
    #latitude from json
    lat = lat_long[0]['lat']
    #longitude from json
    lon = lat_long[0]['lon']
    base_url_weather = "http://api.openweathermap.org/data/2.5/weather?"
    complete_url_weather = base_url_weather + "appid=" + api_key + "&lat=" + str(lat) + "&lon=" + str(lon) + "&units=metric" + "&mode=html"
    LOGGER.info('Getting weather for location: %s', city_name_lat_long)
    response_weather =  requests.get(complete_url_weather)
    s3 = boto3.resource('s3')
    LOGGER.info('Uploading to s3: %s', s3_bucket)
    s3object = s3.Object(s3_bucket, 'index.html')
    s3object.put(Body=(response_weather.content))

def handler(event, context):
    LOGGER.info('Event: %s', event)
    get_weather()
