
from . import charts_blueprint
from flask import render_template, Markup
import plotly.offline as pyo
import os 
import pandas as pd
import plotly.graph_objects as go
import networkx as nx
import pandas as pd
from .helper import networkChart as nw
from .helper import sentEmoChart as smc
import glob

netflix_shows_df = pd.read_csv("./Data/netflix_titles/netflix_titles.csv")
df = pd.read_csv("./Data/netflix_titles/cast_network.csv")
cast_G = nw.generateGraph(df)

pop_df, unpop_df = smc.getData()

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

@charts_blueprint.route("/emo_overview", methods = ["Get"])
def getEmoOverview(): 
    fig = smc.genEmoRadar(pop_df, "popular")
    fig2 = smc.genEmoRadar(unpop_df, "unpopular")

    chart_div_string = pyo.offline.plot(fig, include_plotlyjs=False, output_type='div') 
    chart_div_for_use_in_jinja_template = Markup(chart_div_string)
    chart_div_string2 = pyo.offline.plot(fig2, include_plotlyjs=False, output_type='div')
    chart_div_for_use_in_jinja_template2 = Markup(chart_div_string2)

    return render_template('emo.html', pop=chart_div_for_use_in_jinja_template , unpop=chart_div_for_use_in_jinja_template2)

@charts_blueprint.route("/sent_overview", methods = ["Get"])
def getSentOverview(): 
    fig = smc.genSentRadar(pop_df, "popular")
    fig2 = smc.genSentRadar(unpop_df, "unpopular")
    
    chart_div_string = pyo.offline.plot(fig, include_plotlyjs=False, output_type='div') 
    chart_div_for_use_in_jinja_template = Markup(chart_div_string)
    chart_div_string2 = pyo.offline.plot(fig2, include_plotlyjs=False, output_type='div')
    chart_div_for_use_in_jinja_template2 = Markup(chart_div_string2)

    return render_template('sent.html', pop=chart_div_for_use_in_jinja_template , unpop=chart_div_for_use_in_jinja_template2)

