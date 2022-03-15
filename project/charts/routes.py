
from . import charts_blueprint
from flask import render_template, Markup
import plotly.offline as pyo
import os 
import pandas as pd
import plotly.graph_objects as go
import networkx as nx
import pandas as pd
from .helper import networkChart as nw

netflix_shows_df = pd.read_csv("./Data/netflix_titles/netflix_titles.csv")
df = pd.read_csv("./Data/netflix_titles/cast_network.csv")
cast_G = nw.generateGraph(df)

@charts_blueprint.route("/", methods=["GET"])
@charts_blueprint.route("/index", methods=["GET"])
def welcome():
    return render_template('index.html')

@charts_blueprint.route("/wordcloud/<show>", methods=["GET"])
def getWordCloudSquid(show):
    show = show.lower()
    textWC = os.path.join(f'../static/wc/{show}_text.png')
    hashtagWC = os.path.join(f'../static/wc/{show}_hashtags.png')
    return render_template('wordcloud.html', text_wc = textWC, ht_wc = hashtagWC)

@charts_blueprint.route("/show_network/<show>", methods=["GET"])
def getCastNetwork(show):
    try: 
        casts = netflix_shows_df[netflix_shows_df.title == show].cast.values[0].split(", ")
        fig = nw.getCastNetwork(cast_G, show, casts)
        if (fig == False): 
            return render_template('error.html', error = "Sorry, there is an error generating the network diagram.")
    except:
        return render_template('error.html', error = "Sorry, this show doesn't exist in our current database.")
    chart_div_string = pyo.offline.plot(fig, include_plotlyjs=False, output_type='div')
    chart_div_for_use_in_jinja_template = Markup(chart_div_string)
    return render_template('network.html', chart=chart_div_for_use_in_jinja_template )

