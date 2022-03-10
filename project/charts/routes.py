
from . import charts_blueprint
from flask import render_template, Markup
import plotly.offline as pyo
import os 
import pandas as pd
import plotly.graph_objects as go
import networkx as nx
import pandas as pd
from .helper import networkChart as nw

df = pd.read_csv("./Data/generated/cast_network.csv")
cast_G = nw.generateGraph(df)

@charts_blueprint.route("/", methods=["GET"])
@charts_blueprint.route("/index", methods=["GET"])
def welcome():
    return render_template('index.html')

@charts_blueprint.route("/wordcloud/<show>", methods=["GET"])
def getWordCloudSquid(show):
    textWC = os.path.join(f'../static/{show}_text.png')
    hashtagWC = os.path.join(f'../static/{show}_hashtags.png')
    return render_template('wordcloud.html', text_wc = textWC, ht_wc = hashtagWC)

@charts_blueprint.route("/cast_network/<cast>", methods=["GET"])
def getCastNetwork(cast):
    fig = nw.getCastNetwork(cast_G, cast)
    chart_div_string = pyo.offline.plot(fig, include_plotlyjs=False, output_type='div')
    chart_div_for_use_in_jinja_template = Markup(chart_div_string)
    return render_template('network.html', chart=chart_div_for_use_in_jinja_template )

